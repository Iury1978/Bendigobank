require 'json'
require 'watir'
require 'nokogiri'

class BendigoBank

  def initialize
    @browser = Watir::Browser.new :chrome
  end

  def start
    goto_bank_page
  end

  def goto_bank_page
    @browser.goto('https://demo.bendigobank.com.au/banking/sign_in')
    @browser.window.maximize
    @browser.button(value: 'personal').wait_until(&:present?).click
    sleep 2
  end
end

BendigoBank.new.start