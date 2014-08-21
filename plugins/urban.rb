require 'cinch'
require 'open-uri'
require 'nokogiri'

module Plugins
  class UrbanDictionary
    include Cinch::Plugin
    set(
        plugin_name: 'UrbanDictionary',
        help: "Urban Dictionary -- Grabs a term from urbandictionary.com.\nUsage: `?urban <term>`; `?wotd`; `!?woty`"
    )

    match /urban (.*)/, method: :query
    match /ud (.*)/,    method: :query
    match /wotd/,       method: :wotd
    match /woty/,       method: :woty


    def query(m, query)

      m.reply "UD> #{search(query)}"
    end

    def woty(m)
      url = URI.encode "http://www.urbandictionary.com/woty.php"
      doc = Nokogiri.HTML(open url)
      word = doc.at_css('.word').text.strip[0..500]
      meaning = doc.at_css('.meaning').text.strip[0..500]
      m.reply "UD> #{word} -- #{meaning}"
    end

    def wotd(m)

      url = URI.encode "http://www.urbandictionary.com/"
      doc = Nokogiri.HTML(open url)
      word = doc.at_css('.word').text.strip[0..500]
      meaning = doc.at_css('.meaning').text.strip[0..500]
      m.reply "UD> #{word} -- #{meaning}"
    end

    private
    def search(query)
      # url = URI.encode "http://www.urbandictionary.com/define.php?term=#{query}"
      # Nokogiri.HTML(open url).at_css('.meaning').text.strip[0..500]

      # Load API data
      url = JSON.parse(
          open("http://api.urbandictionary.com/v0/define?term=#{query}").read
      )

      # Return if nothing is found
      return 'No Results found' if url['result_type'] == 'no_results'

      # Return first definition
      url['list'].first['definition'].strip[0..500]
    rescue => e
      e.message
    end
  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::UrbanDictionary