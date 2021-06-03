require 'json'
require 'watir'
require 'watir-scroll'
require 'nokogiri'
require_relative 'account'
require_relative 'transaction'

class BendigoBank

  TRANSACTION_STATUS_PAID = 'paid'
  TRANSACTION_STATUS_REJECTED = 'rejected'
  TRANSACTION_STATUS_PROCESSING = 'processing'
  TRANSACTION_STATUS_INCOMING = 'incomming'

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

  def goto_accounts_page
    @browser.link(text: 'Accounts').wait_until(&:present?).click 
  end

  def goto_account_page(acc_id)
    @browser.li(data_semantic_account_number: "#{acc_id}").wait_until(&:present?).click    
  end

  def parse_accounts
    goto_accounts_page

    html =  @browser.ol(class: "grouped-list__group__items").html
    accounts = get_accounts_id(html)
    accounts.map do |acc_id|
      goto_account_page(acc_id)

      account_html = @browser.div(data_semantic: "account").html
      full_account_info = parse_account(account_html)

      # full_account_info = [available_balance, current_balance, account_name] 
      # parsing_currency_and_available_balance = [currency, available_balance]
      currency = parsing_currency_and_available_balance(full_account_info[0])[0]
      available_balance = parsing_currency_and_available_balance(full_account_info[0])[1]
      current_balance = parsing_current_balance(full_account_info[1])
      account_name = full_account_info[2]
      id = acc_id
      
      # already working here--------------------------------------------------------

    transactions = parse_transactions(account_name)
    # after processing the transactions  return to the list of accounts
    @browser.link(text: 'Accounts').wait_until(&:present?).click
    
    parameters = {
      name:              account_name,
      id:                id,
      currency:          currency,
      available_balance: available_balance,
      current_balance:   current_balance,
      transactions:      transactions
    }
    Account.new(parameters)
      # @accounts << parse_account(account_html, acc_id)
    end

    full_accounts_information = { accounts: @accounts }
    # puts JSON.pretty_generate(full_accounts_information)
    output_to_file(full_accounts_information)
  end
  

  def get_accounts_id(html)
    account_ids_information = Nokogiri::HTML.parse(html)
    #  format data-semantic="account-number-value"  644 303
    account_ids = account_ids_information.css("[data-semantic='account-number-value']").map do |acc_id|
      acc_id.text.delete(' ')
    end
  end

  def parse_account(account_html)
    account_info = Nokogiri::HTML.parse(account_html)
    available_balance = account_info.css("[data-semantic = 'header-available-balance-amount']").text
    current_balance = account_info.css("[data-semantic = 'header-current-balance-amount']").text
    account_name = account_info.css("[data-semantic='account-name']").text

    [available_balance, current_balance, account_name]   
  end

  def parsing_currency_and_available_balance(a_balance)
    # available_balance received data format "$99,999.00"
    currency =  get_currency(a_balance)
    available_balance = a_balance.delete('^((0-9).)').to_f
    [currency, available_balance]
  end

  def parsing_current_balance(c_balance)
    # current_balance received data format "Minus − $264,321.80" or "$99,999.00"
    c_balance.match?(/Minus/) ? (-1) * (c_balance.delete('^((0-9).)')).to_f  : (c_balance.delete('^((0-9).)')).to_f	
  end

  def get_currency(str)
    str.match?(/$/) ? "USD" : "not USD"
  end

  def parse_transactions(account_name)
    select_2_month_transactions

    @browser.div(class: "activity-container").wait_until(&:present?)
    # checking if 'No matching activity found'
    checking = @browser.div(class: "full-page-message__content")
    if checking.present? 
      transactions = []
    else 
      scroll_and_get_all_account_transactions(account_name)
    end
  end

  def select_2_month_transactions
    @browser.link(data_semantic: "filter").wait_until(&:present?).click
    @browser.link(data_semantic: "date-filter").wait_until(&:present?).click
    @browser.li(data_semantic: "custom-date-range-option").wait_until(&:present?).click
    # this part of the code to select an interval of last 7 days
    # often throws out of the program at large intervals

    # @browser.li(data_semantic: "last-7-days-option").wait_until(&:present?).click
    # @browser.button(text: "Apply Filters").click

    # this part of the code to select an interval of 2 months
    @browser.input(data_semantic: "filter-from-date-input").wait_until(&:present?).click
    date_2_month_ago = Date.today.prev_month(2).strftime("%d/%m/%Y")
    @browser.text_field(data_semantic: "filter-from-date-input").set(date_2_month_ago)
      
    @browser.input(data_semantic: "filter-to-date-input").wait_until(&:present?).click
    date_today = Date.today.strftime("%d/%m/%Y")
    @browser.text_field(data_semantic: "filter-to-date-input").set(date_today)

    @browser.button(text: "Apply Filter").wait_until(&:present?).click
    @browser.button(text: "Apply Filters").click
  end

  def scroll_and_get_all_account_transactions(account_name)
    html = @browser.div(data_semantic: "activity-tab-content").html
    transactions_ids = Nokogiri::HTML.parse(html)
    # this cycle loads all transactions for a given period of time. Not all are visible at first
    until transactions_ids.css("[data-semantic = 'end-of-feed-message']").text == 'No more activity'
      @browser.scroll.to :end
      html = @browser.div(data_semantic: "activity-tab-content").html
      transactions_ids = Nokogiri::HTML.parse(html)
    end  

    transactions = transactions_ids.css('a[data-semantic = "activity-anchor"]').map do |element|             
      link = 'https://demo.bendigobank.com.au' + element['href']
      @browser.goto(link)
      # needed to load data
      sleep 3
      html = @browser.div(data_semantic: "transactions-show").html
      transaction_info = Nokogiri::HTML.parse(html)
      # format - Paid on3 May 2021 at 9:43am
      date_unclean = transaction_info.css("[data-semantic='sent-on']").text
      date = DateTime.parse(date_unclean).strftime("%Y-%m-%d")

      description = parse_transaction_description(transaction_info)

      check_debit_or_credit = parse_debit_or_credit(transaction_info)

      currency_amount_unclean = transaction_info.at_css("[data-semantic='payment-amount']").text
      currency_and_amount = parsing_currency_and_amount(currency_amount_unclean, check_debit_or_credit)
      amount = currency_and_amount[1]
      currency = currency_and_amount[0]

      parameters = {
        date:         date,
        description:  description,
        amount:       amount,
        currency:     currency,
        account_name: account_name
      }
      Transaction.new(parameters)
    end
  end

  def parse_debit_or_credit(transaction_info)
    if transaction_info.css('[data-semantic = "stamp-paid"]').text.downcase.match? (/paid/)
      TRANSACTION_STATUS_PAID
    elsif transaction_info.css('[data-semantic = "stamp-rejected"]').text.downcase.match? (/rejected/)
      TRANSACTION_STATUS_REJECTED
    elsif transaction_info.css('[data-semantic = "stamp-processing"]').text.downcase.match? (/processing/)
      TRANSACTION_STATUS_PROCESSING
    else
      TRANSACTION_STATUS_INCOMING
    end
  end
  
  def parsing_currency_and_amount(currency_amount_unclean, check_debit_or_credit)
    # formats - Credit of $50.00  or   $150.00 
    currency =  get_currency(currency_amount_unclean)
    #  can?? regex \d.*\d
    
    amount =  case 
              when check_debit_or_credit == TRANSACTION_STATUS_PAID
                -1 * currency_amount_unclean.delete('^((0-9).)').to_f 
              when check_debit_or_credit == TRANSACTION_STATUS_INCOMING
                currency_amount_unclean.delete('^((0-9).)').to_f
              when check_debit_or_credit == TRANSACTION_STATUS_REJECTED
                TRANSACTION_STATUS_REJECTED
              when check_debit_or_credit == TRANSACTION_STATUS_PROCESSING
                TRANSACTION_STATUS_PROCESSING
              end
    [currency, amount]
  end
  
  def parse_transaction_description(transaction_info)
    description_label = transaction_info.css('[data-semantic="label"]').map do |label|
      label.text.downcase
    end
    description_detail = transaction_info.css('[data-semantic = "detail"]').map do |detail|
      detail.text
    end
    des_first = description_label.shift
    des_second = Hash[description_label.zip(description_detail)]
    des_second['description'].nil? ? description = des_first : description = des_first + ' '  + des_second['description'].squeeze(' ')
  end

  def output_to_file(full_accounts_information)
    File.open("../data/bendigobank_result.txt", "w") do |info|
      info.write(JSON.pretty_generate(full_accounts_information))
    end
  end

end

# BendigoBank.new.start

