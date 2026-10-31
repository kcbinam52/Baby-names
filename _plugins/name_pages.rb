# frozen_string_literal: true

# Builds one page per name at /name/<slug>/ from _data/names.yml and _data/names_more.yml.
# A name page is kept out of Google (noindex) unless it is not marked "verify" AND has
# its own tip_ne text (real editorial value), or config index_all_names is true.
module Namkosh
  class NamePage < Jekyll::PageWithoutAFile
    def initialize(site, entry, rashi)
      super(site, site.source, File.join('name', entry['slug']), 'index.html')
      name = entry['name']
      en = entry['en']
      gender = entry['gender']
      indexable = entry['status'] != 'verify' &&
                  (site.config['index_all_names'] == true || !entry['tip_ne'].to_s.empty?)
      self.content = '{% include name-page.html %}'
      data['layout'] = 'default'
      data['person'] = entry['slug']
      data['permalink'] = "/name/#{entry['slug']}/"
      data['title'] = "#{name} नामको अर्थ | #{en} Name Meaning"
      data['description'] = "#{name} (#{en}) नामको अर्थ, उत्पत्ति र राशि। Meaning, origin and rashi of the #{gender} name #{en}."
      data['crumb'] = "#{name} / #{en}"
      data['crumbs'] = [{ 'name' => "#{rashi['ne']} राशि / #{rashi['slug'].capitalize}", 'url' => "/rashi/#{rashi['slug']}/" }]
      data['updated'] = '2026-10-31'
      data['noindex'] = !indexable
    end
  end

  class NamePageGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      girls = (site.data['names'] || []).map { |n| n.merge('gender' => n['gender'] || 'girl') }
      all = girls + (site.data['names_more'] || [])
      rashi_by_slug = {}
      (site.data['rashi'] || []).each { |r| rashi_by_slug[r['slug']] = r }
      all.each do |entry|
        rashi = rashi_by_slug[entry['rashi']]
        next unless rashi

        site.pages << NamePage.new(site, entry, rashi)
      end
    end
  end
end
