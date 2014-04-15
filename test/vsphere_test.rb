require 'test_helper'
require 'mocha/test_unit'

include RbVmomi
include Mesh

class VSphereTest < Test::Unit::TestCase

  def setup
  end

  def teardown
  end

  #def test_get_machine_uses_vim_connection
  test "get machine gets machine with connection" do
    connection_options = Hash.new
    VIM.stubs(:connect).returns("a string")
    vsphere_vm_manager = VSphere.new(connection_options)
    Machine.expects(:get).returns("fake vm")
    mock_vm = Object.new
    Machine.stubs( :get ).returns(mock_vm)
           #returns( stub(:cool? => true) ) # returns an object with just a .cool? method which in turn returns true

    vm = vsphere_vm_manager.get_machine("fake_machine","fake datacenter")
    
    assert vm == mock_vm
  end
end
