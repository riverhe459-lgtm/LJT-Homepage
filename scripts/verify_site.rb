# frozen_string_literal: true

require 'yaml'
require 'json'
require 'uri'
require 'nokogiri'

def check(condition, message)
  abort("FAIL: #{message}") unless condition
end

root = File.expand_path('_site')
config = YAML.safe_load(File.read('_config.yml'), aliases: true)
publications = YAML.safe_load(File.read('_data/publications.yml'), aliases: true)
expected_pages = ['index.html', 'publications/index.html'].sort
actual_pages = Dir.glob(File.join(root, '**', '*.html')).map do |path|
  path.delete_prefix("#{root}/")
end.sort
check(actual_pages == expected_pages, "Expected only About and Publications HTML pages; found #{actual_pages.inspect}")
check(publications.length == 6, 'Expected the six publications supplied in memory')

base_url = "#{config.fetch('url')}#{config.fetch('baseurl')}/"
base = URI(base_url)
base_path = config.fetch('baseurl')
documents = expected_pages.to_h do |relative|
  [relative, Nokogiri::HTML(File.read(File.join(root, relative)))]
end

placeholders = ['Your Name', 'Your Sidebar Name', 'Red Brick University',
                'none@example.org', 'Paper Title Number', 'Short biography for the left-hand sidebar']

documents.each do |relative, document|
  text = document.text.gsub(/\s+/, ' ')
  placeholders.each { |placeholder| check(!text.include?(placeholder), "Template placeholder in #{relative}: #{placeholder}") }
  check(document.css('.author__avatar').empty?, "No personal photograph was supplied for #{relative}")
  entries = document.css('ol.publication-list > li')
  check(entries.length == publications.length, "Incomplete publication list in #{relative}")
  publications.zip(entries).each do |publication, entry|
    entry_text = entry.text.gsub(/\s+/, ' ')
    check(entry_text.include?(publication.fetch('title')), "Missing publication title in #{relative}")
    publication.fetch('authors').each do |author|
      check(entry_text.include?(author), "Missing author #{author} in #{relative}")
    end
    check(entry_text.include?("#{publication.fetch('venue')}, #{publication.fetch('year')}"), "Wrong venue or year in #{relative}")
    check(entry_text.include?(publication.fetch('contribution')), "Missing authorship role in #{relative}")
    if publication['code_repository']
      check(entry_text.include?(publication['code_repository']), "Missing recorded code repository in #{relative}")
    elsif publication['has_github_code']
      check(entry_text.include?('Code available on GitHub.'), "Missing code-availability note in #{relative}")
    end
  end

  page_url = URI.join(base_url, relative.sub(/index\.html\z/, ''))
  document.css('[href], [src]').each do |element|
    %w[href src].each do |attribute|
      value = element[attribute]
      next if value.nil? || value.empty?
      target = URI.join(page_url.to_s, value)
      next unless %w[http https].include?(target.scheme) && target.host == base.host
      check(target.path.start_with?("#{base_path}/"), "Link escapes project base path in #{relative}: #{value}")
      local = target.path.delete_prefix("#{base_path}/")
      local += 'index.html' if local.empty? || local.end_with?('/')
      destination = File.expand_path(local, root)
      check(destination.start_with?("#{root}/") && File.file?(destination), "Broken local link in #{relative}: #{value}")
      next unless target.fragment && !target.fragment.empty? && destination.end_with?('.html')
      target_document = Nokogiri::HTML(File.read(destination))
      check(target_document.css('[id]').any? { |node| node['id'] == target.fragment }, "Missing anchor in #{relative}: #{value}")
    end
  end
end

about = documents.fetch('index.html')
%w[research-interests academic-background research-experience publications honors-and-awards contact].each do |id|
  check(about.at_css("h2##{id}"), "Missing About section: #{id}")
end
check(about.at_css('h2#publications').next_element.name == 'ol', 'The publication list must be inside the About page, not merely linked')
expected_contacts = [
  'mailto:jliugi@connect.ust.hk',
  'https://github.com/Vicent0205',
  'https://scholar.google.com/citations?hl=en&user=tbK9jl4AAAAJ&view_op=list_works&sortby=pubdate',
  'https://twitter.com/junteng88716710'
]
contacts = about.css('.page__content a[href]').map { |link| link['href'] }
expected_contacts.each { |contact| check(contacts.include?(contact), "Missing memory-provided contact: #{contact}") }

manifest = JSON.parse(File.read(File.join(root, 'images/manifest.json')))
check(manifest.fetch('start_url') == "#{base_path}/", 'Manifest must use the project homepage path')
manifest.fetch('icons').each do |icon|
  check(icon.fetch('src').start_with?("#{base_path}/images/"), 'Manifest icon must use the project base path')
  check(File.file?(File.join(root, icon.fetch('src').delete_prefix("#{base_path}/"))), 'Missing manifest icon')
end

puts 'PASS: exactly two content pages, all six publications on both pages, recorded contacts, no placeholder portrait, and valid internal links.'
