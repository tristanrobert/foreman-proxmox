# frozen_string_literal: true

# Copyright 2019 Tristan Robert

# This file is part of ForemanFogProxmox.

# ForemanFogProxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# ForemanFogProxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with ForemanFogProxmox. If not, see <http://www.gnu.org/licenses/>.

require 'fog/proxmox/helpers/ip_helper'

module ForemanFogProxmox
  module ProxmoxInterfaces
    def editable_network_interfaces?
      true
    end

    def set_nic_identifier(nic, index)
      nic.identifier = format('net%<index>s', index: index) if nic.identifier.empty?
      raise ::Foreman::Exception, _(format('Invalid identifier interface[%<index>s]. Must be net[n] with n integer >= 0', index: index)) unless Fog::Proxmox::NicHelper.nic?(nic.identifier)
    end

    def container?(host)
      host.compute_attributes['type'] == 'lxc'
    end

    def container_nic_name_valid?(nic)
      /^(eth)(\d+)$/.match?(nic.compute_attributes['name'])
    end

    def set_container_interface_name(_host, nic, index)
      nic.compute_attributes['name'] = format('eth%<index>s', index: index) if nic.compute_attributes['name'].empty?
      raise ::Foreman::Exception, _(format('Invalid name interface[%<index>s]. Must be eth[n] with n integer >= 0', index: index)) unless container_nic_name_valid?(nic)
    end

    def set_ip(host, nic, nic_compute_attributes)
      return 'dhcp' if dhcp?(nic_compute_attributes)

      cidr_suffix = nic_compute_attributes['cidr_suffix'] if nic_compute_attributes['cidr_suffix'].present?
      return nic.ip unless container?(host) || cidr_suffix
      unless Fog::Proxmox::IpHelper.cidr_suffix?(nic.compute_attributes['cidr_suffix'])
        raise ::Foreman::Exception, _(format('Invalid Interface Proxmox CIDR IPv4. If IPv4 is not empty, Proxmox CIDR suffix must be an integer between 0 and 32.'))
      end

      Fog::Proxmox::IpHelper.to_cidr(nic.ip, cidr_suffix)
    end

    def to_boolean(value)
      [1, true, '1', 'true'].include?(value)
    end

    def dhcp?(nic_compute_attributes)
      to_boolean(nic_compute_attributes['dhcp']) if nic_compute_attributes['dhcp'].present?
    end

    def host_interfaces_attrs(host)
      host.interfaces.select(&:physical?).each.with_index.reduce({}) do |hash, (nic, index)|
        set_nic_identifier(nic, index)
        set_container_interface_name(host, nic, index) if container?(host)
        nic_compute_attributes = nic.compute_attributes.merge(id: nic.identifier)
        mac = nic.mac
        mac ||= nic.attributes['mac']
        nic_compute_attributes.store(:macaddr, mac) if mac.present?
        interface_compute_attributes = host.compute_attributes['interfaces_attributes'] ? host.compute_attributes['interfaces_attributes'].select { |_k, v| v['id'] == nic.identifier } : {}
        nic_compute_attributes.store(:_delete, interface_compute_attributes[interface_compute_attributes.keys[0]]['_delete']) unless interface_compute_attributes.empty?
        nic_compute_attributes.store(:ip, set_ip(host, nic, nic_compute_attributes))
        nic_compute_attributes.store(:ip6, nic.ip6) if nic.ip6.present?
        hash.merge(index.to_s => nic_compute_attributes)
      end
    end
  end
end
