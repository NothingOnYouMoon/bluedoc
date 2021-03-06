# frozen_string_literal: true

# For repo.issues, repo.docs to implement watch_comment_by_user_ids
# to get watchers on itself, and repo.watch_comment_by_user_ids
module RepoWatchable
  extend ActiveSupport::Concern

  included do
  end

  # Get watch comment status by user_id
  def watch_comment_status_by_user_id(user_id)
    action = self.watch_comment_by_user_actions.where("user_type = 'User' and user_id = ?", user_id).take
    return action.action_option == "ignore" ? "ignore" : "watch" if action

    repo_action =  self.repository.watch_by_user_actions.where("user_type = 'User' and user_id = ?", user_id).take
    return "watch" if repo_action
    "unwatch"
  end

  # watch comment user id list without `ignore` option
  def watch_comment_by_user_ids
    user_ids = self.watch_comment_by_user_actions.where("action_option is null or action_option != ?", "ignore").pluck(:user_id)
    user_ids += self.repository.watch_by_user_ids
    user_ids.uniq!

    user_ids - unwatch_comment_by_user_ids
  end

  def unwatch_comment_by_user_ids
    self.watch_comment_by_user_actions.where("action_option = ?", "ignore").pluck(:user_id)
  end
end
