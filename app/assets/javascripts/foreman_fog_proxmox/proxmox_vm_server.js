// Copyright 2018 Tristan Robert

// This file is part of ForemanFogProxmox.

// ForemanFogProxmox is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// ForemanFogProxmox is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with ForemanFogProxmox. If not, see <http://www.gnu.org/licenses/>.

function attributesPrefixSelector(profile, type) {
  return profile ?  '#compute_attribute_vm_attrs_' + type + '_attributes_': '#host_compute_attributes_' + type + '_attributes_';
}

function volumesAttributesSelector(profile,index,selector) {
  return attributesPrefixSelector(profile,'volumes') + index + '_' + selector;
}

function getIndex(item) {
  var index_id = $(item).attr('id');
  var pattern = /(host_compute_attributes_volumes_attributes_||compute_attribute_vm_attrs_volumes_attributes_)(\d+)[_](.*)/i;
  pattern_a = pattern.exec(index_id);
  var index = pattern_a[2];
  return index;
}

function isProfile() {
  return $(volumesAttributesSelector(true,0,'id')) !== undefined;
}

function controllerSelected(item) {
  var controller = $(item).val();
  var index = getIndex(item);
  var max = computeControllerMaxDevice(controller);
  var profile = isProfile();
  var device_selector = volumesAttributesSelector(profile,index,'device');
  var id_selector = volumesAttributesSelector(profile,index,'id');
  $(device_selector).attr('data-soft-max', max);
  var device = $(device_selector).limitedSpinner('value');
  var id = controller + device;
  $(id_selector).val(id);
}

function deviceSelected(item) {
  var device = $(item).limitedSpinner('value');
  var index = getIndex(item);
  var profile = isProfile();
  var controller_selector = volumesAttributesSelector(profile,index,'controller');
  var id_selector = volumesAttributesSelector(profile,index,'id');
  var controller = $(controller_selector).val();
  var id = controller + device;
  $(id_selector).val(id);
}

function computeControllerMaxDevice(controller) {
  switch (controller) {
    case 'ide':
      return 3;
    case 'sata':
      return 5;
    case 'scsi':
      return 13;
    case 'virtio':
      return 15;
    default:
      return 1;
  }
}