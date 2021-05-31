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

$(document).ready(function () {
  sslVerifyPeerSelected();
  authMethodSelected();
});

function sslVerifyPeerSelected() {
  var selected = $("#compute_resource_ssl_verify_peer").is(':checked');
  var ssl_certs_block = $('#compute_resource_ssl_certs').parents('.clearfix');
  var ssl_certs_textarea = $('#compute_resource_ssl_certs');
  if (selected) {
    ssl_certs_block.show();
    ssl_certs_textarea.show();
  } else {
    ssl_certs_block.hide();
    ssl_certs_textarea.text('');
    ssl_certs_textarea.hide();
  }
}

function enableField(item) {
  $(item).show();
  $(item).removeAttr('disabled');
}

function disableField(item) {  
  $(item).hide();
  $(item).attr('disabled','disabled');
}

function toggleFieldset(method, selected){
  return method === selected ? enableField(authMethodFieldsetId(method)) : disableField(authMethodFieldsetId(method));
}

function authMethods(){
  return ['user_token', 'access_ticket'];
}

function authMethodFieldsetId(method){
  return '#compute_ressource_' + method + '_field_set';
}

function authMethodSelected() {
  var selected = $("#compute_resource_auth_method").val();
  console.log("auth_method="+selected);
  authMethods().forEach(function(method){
    toggleFieldset(method, selected);
  });
}