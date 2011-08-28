# require 'spec_helper'
# require 'active_model'
# 
# describe "Validations" do
#   with_mongo_model
# 
#   before do
#     class Unit
#       inherit Mongo::Model
#       collection :units
# 
#       include ActiveModel::Validations
# 
#       attr_accessor :name, :status
# 
#       validates_presence_of :name
#     end
#   end
# 
#   after{remove_constants :Unit}
# 
#   it "ActiveModel integration smoke test" do
#     unit = Unit.new
#     unit.should be_invalid
#     unit.errors.size.should == 1
#     unit.errors.first.first.should == :name
#     unit.save.should be_false
# 
#     unit.name = 'Zeratul'
#     unit.should be_valid
#     unit.errors.should be_empty
#     unit.save.should be_true
#   end
# end