require 'spec_helper'
require 'file_model/spec/shared_crud'

describe 'Integration with File Model' do
  with_mongo_model
  it_should_behave_like "file model crud"

  before :all do
    class ImageFile; end

    class Unit
      inherit Mongo::Model, Mongo::Model::FileModel
      collection :units

      attr_accessor :name

      mount_file :image, ImageFile
    end
  end
  after(:all){remove_constants :Unit}

  before{@model_class = Unit}
end