module Alchemy
	class PageLayout

		def self.included(base)
			@@definitions ||= read_layouts_file
		end

		def self.element_names_for(page_layout)
			layout_description = get(page_layout)
			if layout_description.blank?
				puts "\n+++ Warning: No Layout Description for #{page_layout} found! in page_layouts.yml\n"
				return []
			else
				layout_description["elements"]
			end
		end

		# Returns the page_layout.yml file. Tries to first load from config/alchemy and if not found from vendor/plugins/alchemy/config/alchemy.
		def self.get_layouts
			@@definitions ||= read_layouts_file
		end

		# Add additional pagelayout definitions. I.E. from your module.
		# Call +Alchemy::PageLayout.add(your_layout_definition)+ in your engine.rb file.
		# You can pass a single layout definition as Hash, or a collection of pagelayouts as Array.
		# Example Pagelayout definitions can be found in the +page_layouts.yml+ from the standard set.
		def self.add(page_layout)
			@@definitions ||= read_layouts_file
			if page_layout.is_a?(Array)
				@@definitions += page_layout
			elsif page_layout.is_a?(Hash)
				@@definitions << page_layout
			else
				raise TypeError
			end
		end

		# Returns the page_layout description found by name in page_layouts.yml
		def self.get(name)
			@@definitions ||= read_layouts_file
			@@definitions.detect{ |a| a["name"].downcase == name.downcase }
		end

		# Returns page layouts ready for Rails' select form helper.
		def self.get_layouts_for_select(language_id, layoutpage = false)
			layouts_for_select = [ [ _("Please choose"), "" ] ]
			selectable_layouts(language_id, layoutpage).each do |layout|
				display_name = I18n.t("alchemy.page_layout_names.#{layout['name']}", :default => layout['name'].camelize)
				layouts_for_select << [display_name, layout["name"]]
			end
			layouts_for_select
		end

		def self.selectable_layouts(language_id, layoutpage = false)
			@@definitions.select do |layout|
				used = layout["unique"] && has_another_page_this_layout?(layout["name"], language_id)
				if layoutpage
					layout["layoutpage"] == true && !used && layout["newsletter"] != true
				else
					layout["layoutpage"] != true && !used && layout["newsletter"] != true
				end
			end
		end

		def self.get_page_layout_names
			a = []
			@@definitions.each{ |l| a << l.keys.first }
			a
		end

		def self.has_another_page_this_layout?(layout, language_id)
			Page.where({:page_layout => layout, :language_id => language_id}).any?
		end

		# Reads the layout definitions from +config/alchemy/page_layouts.yml+.
		# If this can not be found, it takes the default one from Alchemys standard set.
		def self.read_layouts_file
			if File.exists? "#{Rails.root}/config/alchemy/page_layouts.yml"
				layouts = YAML.load_file "#{Rails.root}/config/alchemy/page_layouts.yml"
			end
			if !layouts
				if File.exists? File.join(File.dirname(__FILE__), "../../config/alchemy/page_layouts.yml")
					layouts = YAML.load_file File.join(File.dirname(__FILE__), "../../config/alchemy/page_layouts.yml")
				end
			end
			if !layouts
				raise LoadError, "Could not find page_layouts.yml file! Please run: rails generate alchemy:scaffold"
			end
			layouts
		end

	end
end
