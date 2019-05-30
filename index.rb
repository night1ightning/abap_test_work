require 'nokogiri'
require 'open-uri'

class RateStatistics
  def info 
    parsing
    puts "\n"
    puts "Курс валют от \"#{date_rate}\"".center(120, '-')
    puts "\n\n"
    puts sprintf("%30s %60s","Максимальная стоимость", "Минимальная стоимость")
    puts "\n"
    name_max = "#{max_rate[:name]} #{max_rate[:code]}"
    name_min = "#{min_rate[:name]} #{min_rate[:code]}"
    value_max = "#{max_rate[:value]}"
    value_min = "#{min_rate[:value]}"
    format = "%20s %-40s %20s %-40s"
    puts sprintf(format,"Наименование:", name_max, "Наименование:", name_min )
    puts sprintf(format, "Стоимость:", value_max, "Стоимость:", value_min)
    puts "\n"
    puts ' _ _'*30
  end

  def clear
    @result = nil
  end

	private

  attr_reader :min_rate, :max_rate, :date_rate

  def min_rate=(rate)
    @min_rate ||= rate
    return if @min_rate[:value] < rate[:value]
    @min_rate = rate
  end

  def max_rate=(rate)
    @max_rate ||= rate
    return if @max_rate[:value] > rate[:value]
    @max_rate = rate
  end

  def date_rate=(date)
    @date_rate = date
  end

	def parsing
		@result = begin
      doc = get_current_data
      self.date_rate = doc.xpath('//ValCurs/@Date').first.value

			doc.xpath('//Valute').each do |valute|
        value = valute.xpath('./Value').text.strip
        code  = valute.xpath('./CharCode').text.strip
        name  = valute.xpath('./Name').text.strip
        rate = {
          code:  code, 
          name:  name,
          value: value
        }
        self.min_rate = rate
        self.max_rate = rate
      end
			1
		end
	end

	def get_current_data
		Nokogiri::XML(open('http://www.cbr.ru/scripts/XML_daily.asp'))
	end
end


rate = RateStatistics.new
rate.info

