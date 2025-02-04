module HammerCLIForemanPuppet
  class PuppetClass < HammerCLIForemanPuppet::Command

    resource :puppetclasses

    class ListCommand < HammerCLIForemanPuppet::ListCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      def send_request
        self.class.unhash_classes(super)
      end

      def self.unhash_classes(classes)
        clss = classes.first.inject([]) { |list, (pp_module, pp_module_classes)| list + pp_module_classes }

        HammerCLI::Output::RecordCollection.new(clss, :meta => classes.meta)
      end

      build_options

      extend_with(HammerCLIForemanPuppet::CommandExtensions::PuppetEnvironment.new)
    end

    class InfoCommand < HammerCLIForemanPuppet::InfoCommand
      output ListCommand.output_definition do
        collection :smart_class_parameters, _('Smart class parameters'), :numbered => false do
          custom_field Fields::Reference, :name_key => :parameter
        end
        HammerCLIForeman::References.hostgroups(self)
        HammerCLIForemanPuppet::PuppetReferences.environments(self)
        HammerCLIForeman::References.parameters(self)
      end

      build_options

      extend_with(HammerCLIForemanPuppet::CommandExtensions::PuppetEnvironment.new)
    end


    class SCParamsCommand < HammerCLIForemanPuppet::SmartClassParametersBriefList
      build_options_for :puppetclasses

      def validate_options
        super
        validator.any(:option_puppetclass_name, :option_puppetclass_id).required
      end
    end

    autoload_subcommands
  end
end
