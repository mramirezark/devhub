# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    private

    def locate_record(model_class, id)
      GlobalID::Locator.locate(id) || model_class.find_by(id: id)
    end
  end
end
