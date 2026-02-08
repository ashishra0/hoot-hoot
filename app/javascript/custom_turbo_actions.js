import { Turbo } from "@hotwired/turbo-rails"

// Only replaces the target element if the friendship-id attribute on the
// <turbo-stream> tag matches the dashboard's currently active friendship.
Turbo.StreamActions.replace_if_active = function() {
  const friendshipId = this.getAttribute("friendship-id")
  const dashboard = document.querySelector("[data-dashboard-active-friendship-id-value]")

  if (!dashboard) return

  const activeFriendshipId = dashboard.dataset.dashboardActiveFriendshipIdValue

  if (activeFriendshipId === friendshipId) {
    this.targetElements.forEach((target) => {
      target.replaceWith(this.templateContent.cloneNode(true))
    })
  }
}
