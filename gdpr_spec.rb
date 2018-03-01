require 'rspec'
require_relative 'gdpr'

def reset
  Call.delete_all
  Leg.delete_all
  User.delete_all
end

describe GdprJob do
  before { reset }
  
  it 'scrubs all registered models' do
    call_1 = Call.new({ from: '1', to: '2', direction: 'outbound', user_id: 1 }).tap(&:save)
    GdprJob.new(1, 1).perform
    expect(call_1.to).to eq Gdpr::REPLACE_STRING
  end
end

describe User do
  before { reset }
  
  it 'scrubs' do
    user = User.new(name: 'DummyName').tap(&:save)
    GdprJob.new(1, user.id).perform
    expect(user.name).to eq 'Zendesk'
  end
end

describe Charge do
  before { reset }
  let(:contents)      { {from: '1', to: '2', amount: 10 } }
  let(:new_contents)  { {from: Gdpr::REPLACE_STRING, to: '2', amount: 10 } }
  it 'scrubs' do
    call = Call.new({ from: '1', to: '2', direction: 'inbound', user_id: 'aangelim' }).tap(&:save)
    charge_1 = Charge.new(call: call, name: 'my name', contents: contents.to_json).tap(&:save)
    charge_2 = Charge.new(call: call, name: 'my name', contents: contents.to_json).tap(&:save)
    charge_3 = Charge.new(call: nil, name: 'my name', contents: contents.to_json).tap(&:save)
    
    GdprJob.new('any_account','aangelim').perform
    expect(charge_1.name).to eq(Gdpr::REPLACE_STRING)
    expect(charge_2.name).to eq(Gdpr::REPLACE_STRING)
    expect(charge_2.contents).to eq(new_contents.to_json)
    expect(charge_2.contents).to eq(new_contents.to_json)
    expect(charge_3.name).to eq('my name')
  end
end

describe Transfer do
  before { reset }
  
  it 'scrubs', focus: true do
    transfer = Transfer.new(amount: 1).tap(&:save)
    GdprJob.new(1, 1).perform
    expect(transfer.amount).to eq 10
  end
end

describe Call do
  before { reset }

  let(:call_attrs) { { from: '1', to: '2', direction: 'inbound', user_id: 1 } }

  describe '#inbound? and outbound?' do
    it 'indicates inbound' do
      call = Call.new(call_attrs)
      expect(call).to be_inbound
      expect(call).not_to be_outbound
    end
    it 'does not indicate outbound' do
      call = Call.new(call_attrs)
      call.direction = 'outbound'
      expect(call).to be_outbound
      expect(call).not_to be_inbound
    end
  end

  describe 'scrub' do
    context 'filter' do
      it 'only changes calls for user_id' do
        call_1 = Call.new({ from: '1', to: '2', direction: 'inbound', user_id: 1 }).tap(&:save)
        call_2 = Call.new({ from: '5', to: '6', direction: 'inbound', user_id: 2 }).tap(&:save)
        Call.scrub(1, 1)
        expect(call_1.from).to eq Gdpr::REPLACE_STRING
        expect(call_2.attributes).to include(from: '5', to: '6')
      end
    end
    context 'when inbound' do
      it 'scrubs :from' do
        call_1 = Call.new({ from: '1', to: '2', direction: 'inbound', user_id: 1 }).tap(&:save)
        Call.scrub(1, 1)
        expect(call_1.from).to eq Gdpr::REPLACE_STRING
      end
      it 'preserves :to' do
        call_1 = Call.new({ from: '1', to: '2', direction: 'inbound', user_id: 1 }).tap(&:save)
        Call.scrub(1, 1)
        expect(call_1.to).to eq call_1.to
      end
    end
    context 'when outbound' do
      it 'scrubs :to' do
        call_1 = Call.new({ from: '1', to: '2', direction: 'outbound', user_id: 1 }).tap(&:save)
        Call.scrub(1, 1)
        expect(call_1.to).to eq Gdpr::REPLACE_STRING
      end
      it 'preserves :from' do
        call_1 = Call.new({ from: '1', to: '2', direction: 'outbound', user_id: 1 }).tap(&:save)
        Call.scrub(1, 1)
        expect(call_1.from).to eq call_1.from
      end
    end
  end
end

describe Leg do
  before { reset }
  it 'scrubs' do
    call = Call.new({ from: '1', to: '2', direction: 'inbound', user_id: 'aangelim' }).tap(&:save)
    leg_1 = Leg.new(call: call, phone: '1', name: 'my name').tap(&:save)
    leg_2 = Leg.new(call: call, phone: '2', name: 'my name').tap(&:save)
    leg_3 = Leg.new(call: nil, phone: '1', name: 'my name').tap(&:save)
    GdprJob.new('any_account','aangelim').perform
    expect(call.from).to eq(Gdpr::REPLACE_STRING)
    expect(leg_1.phone).to eq(Gdpr::REPLACE_STRING)
    expect(leg_1.name).to eq(Jobs::LegScrubberJob::NAME_REPLACEMENT)
    expect(leg_2.name).to eq(Jobs::LegScrubberJob::NAME_REPLACEMENT)
    expect(leg_3.name).to eq('my name')
  end
end

