require 'json'
require 'watir'
require 'nokogiri'

class BendigoBank

  def initialize
    @browser = Watir::Browser.new :chrome
  end

  def start
    goto_bank_page
    get_accounts_id
  end

  def goto_bank_page
    @browser.goto('https://demo.bendigobank.com.au/banking/sign_in')
    @browser.window.maximize
    @browser.button(value: 'personal').wait_until(&:present?).click
  end

  def get_accounts_id
    @browser.link(text: 'Accounts').wait_until(&:present?).click
    # with Nokogiri
    html =  @browser.ol(class: "grouped-list__group__items").html
    account_ids_information = Nokogiri::HTML.parse(html)
    account_ids = account_ids_information.css("[data-semantic='account-number-value']").map do |acc_id|
      acc_id.text.delete(' ')
      end
    # with Watir only
    # account_ids_watir = @browser.lis(data_semantic: "account-item").map do |li|
    #   li.attributes[:data_semantic_account_number]
    #   end
    # account_ids_watir.pop
  end

  


end

BendigoBank.new.start