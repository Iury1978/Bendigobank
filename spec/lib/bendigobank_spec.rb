require "bendigobank"
require "spec_helper"


describe "BendigoBank" do

  before (:all) do
    @bank =  BendigoBank.new
  end

  it "can parse accounts" do    
    html = File.open(File.dirname(__FILE__) + '/../fixtures/01_get_accounts_id.html')
    accounts = @bank.get_accounts_id(html)
    expect(accounts.size).to be 5
    expect(accounts).to be_kind_of(Array)
  end

  it "can parse account" do
    account_html = File.open(File.dirname(__FILE__) + '/../fixtures/02_get_account_info.html')
    account = @bank.parse_account(account_html)
    expect(account).to be_kind_of(Array)
    expect(account.size).to  be  3
  end

  it "can get transactions links" do
    transactions_html = File.open(File.dirname(__FILE__) + '/../fixtures/03_02_get_transactions_id.html')
    account = @bank.get_links_account_transactions(transactions_html)
    expect(account).to be_kind_of(Array)
    expect(account.size).to  be  > 0
  end

  it "can dont get transactions links" do
    transactions_html = File.open(File.dirname(__FILE__) + '/../fixtures/03_01_get_transactions_id_if_no_transactions.html')
    account = @bank.get_links_account_transactions(transactions_html)
    expect(account).to be_kind_of(Array)
    expect(account.size).to  be   0
  end

  it "can parsing debit_or_credit" do
    TRANSACTION_STATUS_PAID = 'paid'
    TRANSACTION_STATUS_REJECTED = 'rejected'
    TRANSACTION_STATUS_PROCESSING = 'processing'
    TRANSACTION_STATUS_INCOMING = 'incomming'

    paid_html = File.open(File.dirname(__FILE__) + '/../fixtures/05_01_Transaction_status_paid.html')
    paid = @bank.parse_debit_or_credit(paid_html)
    expect(paid).to eq TRANSACTION_STATUS_PAID

    rejected_html = File.open(File.dirname(__FILE__) + '/../fixtures/05_02_Transaction_status_rejected.html')
    rejected = @bank.parse_debit_or_credit(rejected_html)
    expect(rejected).to eq TRANSACTION_STATUS_REJECTED

    incoming_html = File.open(File.dirname(__FILE__) + '/../fixtures/05_03_Transaction_status_incoming.html')
    incoming = @bank.parse_debit_or_credit(incoming_html)
    expect(incoming).to eq TRANSACTION_STATUS_INCOMING

    processing_html = File.open(File.dirname(__FILE__) + '/../fixtures/05_04_Transaction_status_processing.html')
    processing = @bank.parse_debit_or_credit(processing_html)
    expect(processing).to eq TRANSACTION_STATUS_PROCESSING
  end

  it "can parsing transaction date" do
    transaction_html = File.open(File.dirname(__FILE__) + '/../fixtures/04_transaction_info.html')
    date = @bank.parse_transaction_date(transaction_html)
    expect(date ).to be_kind_of(String)
    expect(date.size).to be > 0
    date_unclean = "Paid on3 May 2021 at 9:43am"
    expect(DateTime.parse(date_unclean).strftime("%Y-%m-%d")). to eq "2021-05-03"
  end

  it "can parsing transaction description" do
    transaction_html = File.open(File.dirname(__FILE__) + '/../fixtures/04_transaction_info.html')
    description = @bank.parse_transaction_description(transaction_html)
    expect(description).to be_kind_of(String)
    expect(description.size).to be > 0
  end

  it "can parsing transaction amount and currency" do
    transaction_html = File.open(File.dirname(__FILE__) + '/../fixtures/04_transaction_info.html')
    amount_currency = @bank.parse_transaction_amount_currency(transaction_html)
    expect(amount_currency).to be_kind_of(Array)
    expect(amount_currency.size).to be 2
  end

  it "can parsing current balance" do
    expect(@bank.parsing_current_balance "$99,999.01").to be_kind_of Float
    expect(@bank.parsing_current_balance "99,99.01").to eq 9999.01
    expect(@bank.parsing_current_balance "Minus − $264,321.80"). to eq -264321.80
  end

  it "can get currency" do
    expect(@bank.get_currency "$99,99.01").to eq "USD"
    expect(@bank.get_currency "99,99.01").to eq "not USD"
  end    

  it " can parse currency and available balance" do
    examlpe = '$99,999.01'
    expect(@bank.parsing_currency_and_available_balance examlpe).to be_kind_of Array
    expect(@bank.parsing_currency_and_available_balance examlpe).to eq ["USD", 99999.01]
    expect(@bank.parsing_currency_and_available_balance 'Rub9923,23.06').to eq ["not USD", 992323.06]
  end

  it "can get transactions info" do
    transactions_links = []
    account_name = 'Sample'
    expect(@bank.get_transactions_info(transactions_links,account_name)).to be_kind_of(Array)
  end

  it "page loaded incorrectly" do
    html = File.open(File.dirname(__FILE__) + '/../fixtures/06_something_went_wrong.html')
    check = @bank.checking_wrong(html)
    expect(check).to be true
  end

  it "page loaded correctly" do
    html = File.open(File.dirname(__FILE__) + '/../fixtures/03_02_get_transactions_id.html')
    check = @bank.checking_wrong(html)
    expect(check).to be false
  end


end