require 'json'
require 'watir'
require 'nokogiri'
require_relative 'account'


class BendigoBank

  def initialize
    @browser = Watir::Browser.new :chrome
    @accounts = []
  end

  def start
    goto_bank_page
    parse_accounts
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

  def parse_accounts
    get_accounts_id.map do |acc_id|
      @browser.li(data_semantic_account_number: "#{acc_id}").wait_until(&:present?).click
      html = @browser.div(data_semantic: "account").html
      account_info = Nokogiri::HTML.parse(html)

      @accounts << parse_account(account_info, acc_id)
      end
  end
  
  def parse_account(account_info, acc_id)
  	available_balance = account_info.css("[data-semantic = 'header-available-balance-amount']").text
  	# available_balance received data format "$99,999.00"
  	current_balance = account_info.css("[data-semantic = 'header-current-balance-amount']").text
  	# current_balance received data format "Minus − $264,321.80" or "$99,999.00"

  	name = account_info.css("[data-semantic='account-name']").text
    id = acc_id
  	currency = parsing_currency_and_available_balance(available_balance)[0]
  	available_balance = parsing_currency_and_available_balance(available_balance)[1]
  	current_balance = parsing_current_balance(current_balance)
    
    parameters = {
    name:              name,
    id:                id,
    currency:          currency,
    available_balance: available_balance,
    current_balance:   current_balance
    }

    Account.new(parameters)

  end

  def parsing_currency_and_available_balance(a_balance)
    currency =  a_balance.match?(/$/) ? "USD" : "not USD"
    available_balance = a_balance.delete('^((0-9).)').to_f
    [currency,available_balance]
  end

  def parsing_current_balance(c_balance)
    c_balance.match?(/Minus/) ? (-1) * (c_balance.delete('^((0-9).)')).to_f  : (c_balance.delete('^((0-9).)')).to_f	
  end
end

BendigoBank.new.start