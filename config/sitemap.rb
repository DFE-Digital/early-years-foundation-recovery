# Example of automated authentication in pa11y-ci config:
#
#   "urls": [
#     {
#       "url": "http://app:3000/my-modules",
#       "actions": [
#         "wait for path to be /users/sign-in",
#         "set field #user-email-field to completed@example.com",
#         "set field #user-password-field to StrongPassword",
#         "click element #sign-in",
#         "wait for element h2#govuk-notification-banner-title to be visible",
#         "screen capture /tmp/images/my-modules.png"
#       ]
#     }
#   ]
#
SitemapGenerator::Sitemap.default_host = Rails.application.config.service_url
SitemapGenerator::Sitemap.compress = false

# Run this command to update /public/sitemap.xml
#
# ./bin/docker-rails sitemap:refresh:no_ping
#
# NB: `app._routes.named_routes.helper_names`
#
SitemapGenerator::Sitemap.create do

  # static pages
  Page.order(:heading).load.each do |page|
    add static_path(page.name)
  end

  # settings
  add setting_path('cookie-policy')

  # errors
  add '/404'
  add '/500'
  add '/503'

  add course_overview_path
  add experts_path
  add feedback_index_path

  Course.config.pages.each do |page|
    add feedback_path(page.name)
  end

  add new_user_session_path

  # account
  add user_path

  # account preferences
  add edit_registration_terms_and_conditions_path
  add edit_registration_name_path
  add edit_registration_setting_type_path
  add edit_registration_setting_type_other_path
  add edit_registration_local_authority_path
  add edit_registration_role_type_path
  add edit_registration_role_type_other_path
  add edit_registration_early_years_experience_path
  add edit_registration_training_emails_path

  # account closure
  add edit_reason_user_close_account_path
  add confirm_user_close_account_path
  add user_close_account_path

  # learning
  add my_modules_path
  add user_notes_path

  # course content
  if Training::Module.live.any?
    mod = Training::Module.live.sample
    add about_path(mod.name)

    mod.content.each do |page|
      if page.is_question?
        add training_module_question_path(page.parent.name, page.name)
      elsif page.assessment_results?
        add training_module_assessment_path(page.parent.name, page.name)
      else
        add training_module_page_path(page.parent.name, page.name)
      end
    end
  end
end
