# HootHoot - Knowledge Document

## What is HootHoot?

An owl-themed social poke & streak app. Friends send "hoots" (pokes) to each other daily and build Snapchat-style streaks. Built with a premium blue color palette.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Rails 8.1, Ruby 3.4 |
| Frontend | Hotwire (Turbo + Stimulus), TailwindCSS v4 |
| Database | SQLite3 |
| Real-time | ActionCable via Turbo Streams (async adapter in dev) |
| Jobs | Solid Queue (nightly streak resets) |
| Auth | `has_secure_password` + `authenticate_by` (no Devise) |

---

## How to Run

```bash
cd hoothoot

# Install dependencies
bundle install

# Setup database
bin/rails db:migrate

# (Optional) Seed test data
bin/rails db:seed

# Start all services (web + tailwind watch + job worker)
bin/dev
```

Open http://localhost:3000

Seed credentials: `alice@test.com` / `password123` and `bob@test.com` / `password123`

---

## Architecture Overview

### Data Models

**User** - email, username (unique, 3-20 chars, alphanumeric + underscore), password_digest, display_name

**Friendship** - Normalized bidirectional (always stored with `user_id < friend_id`). One row per friendship. Embeds streak state directly to avoid joins.

| Column | Purpose |
|--------|---------|
| user_id / friend_id | The two friends (user_id always < friend_id) |
| current_streak | Days both have hooted consecutively |
| longest_streak | All-time best streak |
| streak_date | Last date both hooted (streak was incremented) |
| user_hooted_today | Has user_id hooted today? |
| friend_hooted_today | Has friend_id hooted today? |

**Hoot** - Append-only audit log. Has sender_id, receiver_id, friendship_id, created_at. No updated_at (immutable records).

**Invite** - Token-based invite links. Token is 12-char alphanumeric, expires in 7 days. Tracks who claimed it.

### Key Design Decisions

1. **Single-row friendships**: Instead of two mirrored rows, we store one row with `user_id < friend_id`. The `normalize_ids` callback enforces this. `Friendship.between(user_a, user_b)` finds the canonical row regardless of argument order.

2. **Streak embedded on Friendship**: No separate Streak model. Dashboard loads one query per friendship with all streak data included.

3. **Hybrid streak evaluation**: Lazy refresh on dashboard load (`StreakService.refresh!`) + nightly bulk reset via `StreakResetJob`. Lazy handles active users; the job handles pairs where neither user opens the app.

4. **No Redis**: ActionCable uses `async` adapter in development (in-process). Production uses `solid_cable` (SQLite-backed).

---

## Streak Logic (StreakService)

Located at `app/services/streak_service.rb`. This is the most critical piece of business logic.

### How it works

1. **When User A hoots User B** (`StreakService.record_hoot`):
   - Check if streak is stale (streak_date more than 1 day old) -> reset to 0
   - If new day (streak_date is yesterday) -> reset today's flags
   - Mark sender's `hooted_today` flag
   - If BOTH flags are true AND streak hasn't been incremented today -> increment streak

2. **Dashboard load** (`StreakService.refresh!`):
   - If streak_date is stale -> reset streak
   - If new day -> reset today's flags
   - Does NOT create hoots, just ensures displayed data is current

3. **Nightly job** (`StreakService.reset_stale_streaks!`):
   - Bulk resets all friendships where streak_date is before yesterday

### Edge cases handled

- Multiple hoots same day: Idempotent (flag stays true, streak doesn't double-count)
- Neither user opens app for days: Nightly job catches it
- Friendship created mid-day, both hoot immediately: Works correctly (streak goes to 1)
- Timezone: Uses `Date.current` (UTC in v1)

---

## Hooting

Users can send **unlimited hoots** per day to each friend (like Snapchat snaps after securing a streak). The hoot button is always active. A small "Streak secured" checkmark appears below the button once the user has hooted today, but the button remains clickable.

Each hoot plays a real owl "hoo-HOO" sound effect (`public/sounds/hoot.wav`, ~67KB). The sound plays both on **send** (via `hoot_button_controller.js`) and on **receive** (via `toast_controller.js` with a `data-toast-sound-value`).

The streak logic is idempotent: the `hooted_today` flag is set on the first hoot and stays true. Additional hoots create more Hoot records (audit trail) but don't double-count the streak.

---

## Real-Time Notifications

When a hoot is created, the `after_create_commit` callback queues `HootNotificationJob`, which broadcasts two Turbo Streams to the receiver:

1. **Toast notification** - Appended to `#hoot-notifications` div, plays the owl hoot sound, auto-dismisses after 4s
2. **Friendship card replacement** - Updates the streak display and hoot button state

The receiver subscribes via `turbo_stream_from "user_#{current_user.id}_hoots"` in the dashboard view.

---

## Invite Flow

Four scenarios when someone clicks an invite link (`/i/:token`):

| Scenario | What happens |
|----------|-------------|
| Logged in, not friends | Shows "Accept" page, POST creates friendship |
| Logged in, already friends | Redirects with "Already friends!" |
| Not logged in, has account | Stores token in session -> login -> auto-redirect to claim |
| Not logged in, no account | Stores token in session -> signup -> auto-redirect to claim |

---

## File Map

```
app/
  controllers/
    application_controller.rb    # current_user, require_authentication
    pages_controller.rb          # Landing page
    registrations_controller.rb  # Signup
    sessions_controller.rb       # Login/logout
    dashboard_controller.rb      # Main dashboard (loads friendships, refreshes streaks)
    invites_controller.rb        # Generate, show, claim invite links
    friendships_controller.rb    # Remove friends
    hoots_controller.rb          # Create hoots (the core action)
  models/
    user.rb                      # has_secure_password, normalizes email/username
    friendship.rb                # Normalized bidirectional, streak columns
    hoot.rb                      # Append-only, triggers StreakService + notification job
    invite.rb                    # Token generation, expiry
  services/
    streak_service.rb            # ALL streak logic (record_hoot, refresh!, reset_stale_streaks!)
  jobs/
    hoot_notification_job.rb     # Broadcasts Turbo Streams to receiver via ActionCable
    streak_reset_job.rb          # Nightly stale streak cleanup
  helpers/
    streak_helper.rb             # streak_emoji(), streak_status_text()
  views/
    layouts/application.html.erb # Main layout with navbar, flash, notification container
    pages/landing.html.erb       # Hero + features + footer
    registrations/new.html.erb   # Signup form
    sessions/new.html.erb        # Login form
    dashboard/show.html.erb      # Friend cards with Turbo Stream subscription
    friendships/_card.html.erb   # Friend card (avatar, streak, status, hoot button)
    friendships/_hoot_button.html.erb  # Always-active button + "Streak secured" badge
    hoots/create.turbo_stream.erb      # Replaces friendship card after hooting
    hoots/_notification.html.erb       # Toast notification partial
    invites/index.html.erb       # List invite links + generate new
    invites/show.html.erb        # Accept invite page
    invites/_invite.html.erb     # Single invite row with copy button
    shared/_navbar.html.erb      # Top nav with logo, invite button, username, logout
    shared/_flash.html.erb       # Auto-dismissing flash messages
  javascript/controllers/
    flash_controller.js          # Auto-dismiss flash messages
    toast_controller.js          # Auto-dismiss toast notifications
    hoot_button_controller.js    # Bounce animation + hoot sound on send
    clipboard_controller.js      # Copy invite link to clipboard
  assets/tailwind/
    application.css              # Custom theme: hoot color scale, animations, fonts
public/
  sounds/
    hoot.wav                     # Owl "hoo-HOO" sound effect (~67KB, synthesized)
```

---

## UI Theme

### Color Palette (defined in `app/assets/tailwind/application.css`)

| Token | Hex | Usage |
|-------|-----|-------|
| hoot-50 | #eef4ff | Light backgrounds, hover states |
| hoot-100 | #d9e6ff | Borders, subtle backgrounds |
| hoot-200 | #bcd2ff | Secondary accents |
| hoot-500 | #3366ff | **Primary action color** (buttons, links) |
| hoot-600 | #1a44f5 | Button hover states |
| hoot-950 | #121b57 | Dark text, headings |
| streak-500 | #f59e0b | Streak counters (amber/gold) |
| surface-50 | #f8fafc | Page background |

### Fonts
- **Display** (headings): DM Sans
- **Body**: Inter

### Custom Animations
- `animate-pulse-glow` - Hoot button pulsing blue glow
- `animate-hoot-bounce` - Satisfying bounce when hooting
- `animate-slide-in/out` - Toast notification entrance/exit
- `animate-fade-in-up` - Page content entrance

---

## Known Gotchas

1. **Hoot button Stimulus controller**: Must NOT set `disabled = true` on the button synchronously - this prevents the Turbo form submission. Uses `requestAnimationFrame` + `pointerEvents: none` instead.

2. **Hoot model timestamps**: Only has `created_at` (no `updated_at`). Uses `self.record_timestamps = false` with a manual `before_create` to set `created_at`.

3. **Friendship normalization**: The `before_validation :normalize_ids` callback swaps user_id and friend_id to ensure `user_id < friend_id`. All queries for "this user's friendships" must use `WHERE user_id = ? OR friend_id = ?`.

4. **ActionCable in development**: Uses `async` adapter (in-process only). Broadcasts from background jobs work because the async job adapter also runs in-process. For multi-process production, use `solid_cable`.

5. **`bin/dev` vs `bin/rails server`**: Use `bin/dev` to run all processes (web + tailwind + jobs). Running `bin/rails server` alone won't compile Tailwind or process background jobs.
