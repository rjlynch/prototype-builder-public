namespace :seeds do
  # Regenerates db/seeds/eytrp_wizard.json from the live "EYTRP" wizard so the
  # development seed (db/seeds.rb) tracks the wizard as it's edited. Run this
  # after changing the real wizard, then commit the updated fixture.
  #
  #   bin/rails seeds:dump_eytrp
  #
  # Only the columns the seed rebuilds from are captured (no ids, timestamps or
  # foreign keys), nested page -> component -> branch_rule -> condition.
  desc "Dump the EYTRP wizard to db/seeds/eytrp_wizard.json for the dev seeds"
  task dump_eytrp: :environment do
    require "json"

    wizard = Wizard.find_by(name: "EYTRP")
    abort "No wizard named \"EYTRP\" found — nothing to dump." unless wizard

    page_cols = %w[back_link caption heading_size panel_style position slug title]
    comp_cols = %w[button_style display_as_link hint in_panel inline kind label
                   list_spaced list_style name options position source_key
                   summary_keys target_slug text title_as_label]
    rule_cols = %w[position target_slug]
    cond_cols = %w[input_name position value]

    data = {
      "name" => wizard.name,
      "pages" => wizard.pages.order(:position).map do |page|
        page.attributes.slice(*page_cols).merge(
          "components" => page.components.order(:position).map do |component|
            component.attributes.slice(*comp_cols).merge(
              "branch_rules" => component.branch_rules.order(:position).map do |rule|
                rule.attributes.slice(*rule_cols).merge(
                  "conditions" => rule.conditions.order(:position).map { |condition|
                    condition.attributes.slice(*cond_cols)
                  }
                )
              end
            )
          end
        )
      end
    }

    path = Rails.root.join("db/seeds/eytrp_wizard.json")
    path.write(JSON.pretty_generate(data))

    components = data["pages"].sum { |page| page["components"].size }
    puts "Wrote #{path.relative_path_from(Rails.root)} " \
         "(#{data["pages"].size} pages, #{components} components, #{path.size} bytes)"
  end
end
