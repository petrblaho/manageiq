module ManageIQ::Providers::Openstack::InfraManager::Host::Operations
  include ActiveSupport::Concern

  def ironic_fog_node
    connection_options = {:service => "Baremetal"}
    ext_management_system.with_provider_connection(connection_options) do |service|
      service.nodes.get(uid_ems)
    end
  end

  def set_node_maintenance
    ironic_fog_node.set_node_maintenance(:reason=>"CFscaledown")
  end

  def unset_node_maintenance
    ironic_fog_node.unset_node_maintenance
  end

  def external_get_node_maintenance
    ironic_fog_node.maintenance
  end

  def nova_compute_system_service
    # we need to be sure that host has compute service
    system_services.find_by(:name => 'openstack-nova-compute')
  end

  def nova_compute_fog_service
    # TODO: check if host is part of OpenStack Infra
    # host's cluster needs cloud assigned
    if cloud = ems_cluster.try(:cloud)
      # binding.pry
      # hostname of host in hypervisor is used to properly select service from OpenStack
      host_name = hypervisor_hostname
      fog_services = cloud.openstack_handle.compute_service.services
      fog_services.find { |s| s.host =~ /#{host_name}/ && s.binary == 'nova-compute' }
    end
  end

  def nova_compute_enable_scheduling
    nova_compute_fog_service.enable
  end

  def nova_compute_disable_scheduling
    nova_compute_fog_service.disable
  end
end
