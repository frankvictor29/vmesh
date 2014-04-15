require 'rbvmomi'
require 'logger'

module Mesh
  class Machine
    attr_accessor :name, :vm
    def initialize(vm)
      Mesh::logger.debug "New machine wrapper object with #{vm}"
      @vm = vm    #root_folder.traverse @name, RbVmomi::VIM::VirtualMachine
    end

    def self.get(vim, datacenter_name, name)
      Mesh::logger.debug "looking for vm #{name} at dc #{datacenter_name}."
      root_folder = vim.serviceInstance.content.rootFolder
      Mesh::logger.debug "not sure we found the root folder champ." unless root_folder
      template_vm = root_folder.traverse(datacenter_name).vmFolder.traverse(name)
      template_vm or raise "unable to find template #{name} at #{datacenter_name}"
      Machine.new template_vm
    end

    def power_on
      raise NotImplementedError 
    end

    def command
      raise NotImplementedError
    end

    def describe
      raise NotImplementedError
    end

    def template?
      raise NotImplementedError
    end

    def ipAddress
      @vm.guest.ipAddress
    end

    def clone (vm_name, vm_folder = '/', datastore = nil, custom_spec = nil, pool = nil)
      Mesh::logger.info "Cloning #{@name} to a new vm named #{vm_name} in folder #{vm_folder}."

      relocateSpec = RbVmomi::VIM.VirtualMachineRelocateSpec(:datastore    => datastore,
                                                             :diskMoveType => :moveChildMostDiskBacking,
                                                             :pool         => pool)

      clone_spec = RbVmomi::VIM.VirtualMachineCloneSpec(:location => relocateSpec,
                                                        :powerOn  => false,
                                                        :template => false)
      clone_spec.customization = custom_spec.spec if custom_spec

      Mesh::logger.warn "Haven't implemented destination folder location, will be found in the template's folder"
      Machine.new(@vm.CloneVM_Task(:folder => @vm.parent, :name => vm_name, :spec => clone_spec).wait_for_completion)
    end
  end
end
