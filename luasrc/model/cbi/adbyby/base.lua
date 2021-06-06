local NXFS = require "nixio.fs"
local SYS  = require "luci.sys"
local HTTP = require "luci.http"
local DISP = require "luci.dispatcher"

local UD = NXFS.readfile("/tmp/adbyby.updated") or translate("Never Update")

m = Map("adbyby")

m:section(SimpleSection).template = "adbyby/adbyby_status"

s = m:section(TypedSection, "adbyby")
s.anonymous = true

o = s:option(Flag, "enable")
o.title = translate("Enable")
o.default = 0
o.rmempty = false

o = s:option(ListValue, "wan_mode")
o.title = translate("Running Mode")
o:value("0", translate("Global Mode"))
o:value("1", translate("Filter Mode"))
o:value("2", translate("Manual Mode"))
o.default = 1
o.rmempty = false

o = s:option(Button, "restart")
o.title = translate("Rule State")
o.inputtitle = translate("Update Manually")
o.description = string.format("<strong>"..translate("Last Update")..":</strong> %s", UD)
o.inputstyle = "reload"
o.write = function()
	SYS.call("rm -rf /tmp/adbyby.updated /tmp/adbyby/admd5.json && /usr/share/adbyby/adbybyupdate.sh > /tmp/adupdate.log 2>&1 &")
    SYS.call("sleep 2")
	HTTP.redirect(DISP.build_url("admin", "services", "adbyby"))
end

t = m:section(TypedSection, "acl_rule", translate("<strong>Client Filter Mode Settings</strong>"), translate("Set different filter mode for LAN clients"))
t.template = "cbi/tblsection"
t.sortable = true
t.anonymous = true
t.addremove = true

e = t:option(Value, "ipaddr", translate("IP Address"))
e.width = "50%"
e.datatype = "ip4addr"
e.placeholder = "0.0.0.0/0"
luci.ip.neighbors({ family = 4 }, function(entry)
	if entry.reachable then
		e:value(entry.dest:string())
	end
end)

e = t:option(ListValue, "filter_mode", translate("Filter Mode"))
e.width = "50%"
e.default = "disable"
e.rmempty = false
e:value("disable", translate("No Filter"))
e:value("global", translate("Global Filter"))

return m