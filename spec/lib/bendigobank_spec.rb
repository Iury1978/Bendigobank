require "bendigobank"
require "spec_helper"


describe "BendigoBank" do
  
  it "can parse accounts" do
    bank =  BendigoBank.new
    html = File.open(File.dirname(__FILE__) + '/../fixtures/01_get_accounts_id.html')
    accounts = bank.get_accounts_id(html)
    expect(accounts.size).to be 5
    expect(accounts).to be_kind_of(Array)
    end

  it "can parse account" do
    bank =  BendigoBank.new
    account_html = File.open(File.dirname(__FILE__) + '/../fixtures/02_get_account_info.html')
    account = bank.parse_account(account_html)
    expect(account).to be_kind_of(Array)
    expect(account.size).to  be  3
    expect(account[0].size).to be  > 0
    expect(account[1].size).to be  > 0
    expect(account[2].size).to be  > 0
    end
  

end