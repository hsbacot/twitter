require 'helper'

describe Twitter::Streaming::Event do

  describe '#initialize' do
    before(:each) do
      @data = {'event' => 'follow', 'source' => {'id' => 10_083_602}, 'target' => {'id' => 1_292_911_088}}
    end
    subject do
      Twitter::Streaming::Event.new(@data)
    end
    it 'should set the name to be a symbolised version of string string' do
      expect(subject.name).to eq('follow')
    end
    it 'should set the source to be the User' do
      expect(subject.source).to be_a(Twitter::User)
      expect(subject.source.id).to eq(10_083_602)
    end
    it 'should set the target to be the User' do
      expect(subject.target).to be_a(Twitter::User)
      expect(subject.target.id).to eq(1_292_911_088)
    end
    context 'when target object is a list' do
      before(:each) do
        @data = {'event' => 'list_member_added', 'target_object' => {'id' => 60_314_359, 'full_name' => '@adambird/lists/dev'}, 'source' => {'id' => 10_083_602}, 'target' => {'id' => 1_292_911_088}}
      end
      it 'should have the list object as the target object' do
        expect(subject.target_object).to be_a(Twitter::List)
        expect(subject.target_object.full_name).to eq('@adambird/lists/dev')
      end
    end
    context 'when target object is a tweet' do
      before(:each) do
        @data = {'event' => 'favorite', 'target_object' => {'id' => 394_454_214_132_256_768}, 'target' => {'id' => 1_292_911_088}, 'source' => {'id' => '10_083_602'}}
      end
      it 'should have the tweet as the target object' do
        expect(subject.target_object).to be_a(Twitter::Tweet)
        expect(subject.target_object.id).to eq(394_454_214_132_256_768)
      end
    end
  end

end
