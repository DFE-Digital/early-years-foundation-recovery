module SidebarHelper
  def about_sidebar_items(modules)
    items = [
      {
        key: :course,
        text: t('about.heading'),
        href: course_overview_path,
      },
    ]

    items.concat(
      modules.map do |mod|
        {
          key: mod.name,
          text: mod.heading,
          href: about_path(mod.name),
        }
      end,
    )

    items << {
      key: :experts,
      text: t('experts.heading'),
      href: experts_path,
    }

    items
  end

  def notes_sidebar_items(modules)
    modules.map do |mod|
      {
        key: mod.name,
        text: mod.title,
        href: module_notes_user_path(module_name: mod.name),
      }
    end
  end
end
