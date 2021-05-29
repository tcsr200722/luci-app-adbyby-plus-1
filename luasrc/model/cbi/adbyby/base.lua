local NXFS = require "nixio.fs"
local SYS  = require "luci.sys"
local HTTP = require "luci.http"
local DISP = require "luci.dispatcher"

local NR = SYS.exec("grep -v '^!' /usr/share/adbyby/data/rules.txt | wc -l")
local NU = SYS.exec("cat /usr/share/adbyby/data/user.txt | wc -l")
local UD = NXFS.readfile("/tmp/adbyby.updated") or "1970-01-01 00:00:00"

m = Map("adbyby")
m.title	= translate("Adbyby Plus + Settings")

m:section(SimpleSection).template  = "adbyby/adbyby_status"

s = m:section(TypedSection, "adbyby")
s.anonymous = true

o = s:option(Flag, "enable")
o.title = translate("Enable")
o.default = 0
o.rmempty = false

o = s:option(ListValue, "wan_mode")
o.title = translate("Running Mode")
o:value("0", translate("Global Mode (The slowest and the best effects)"))
o:value("1", translate("Plus + Mode (Filter domain name list and blacklist website.Recommended)"))
o:value("2", translate("No filter Mode (Must set in Client Filter Mode Settings manually)"))
o.default = 1
o.rmempty = false

o = s:option(Button, "restart")
o.title = translate("Adbyby and Rule state")
o.inputtitle = translate("Update Adbyby Rules Manually")
o.description = string.format("<strong>"..translate("Last Update Checked")..":</strong> %s", UD)
o.inputstyle = "reload"
o.write = function()
	SYS.call("rm -rf /tmp/adbyby.updated /tmp/adbyby/admd5.json && /usr/share/adbyby/adbybyupdate.sh > /tmp/adupdate.log 2>&1 &")
    SYS.call("sleep 5")
	HTTP.redirect(DISP.build_url("admin", "services", "adbyby"))
end

t=m:section(TypedSection,"acl_rule",translate("<strong>Client Filter Mode Settings</strong>"),
translate("Filter mode settings can be set to specific LAN clients ( <font color=blue> No filter , Global filter </font> ) . Does not need to be set by default."))
t.template="cbi/tblsection"
t.sortable=true
t.anonymous=true
t.addremove=true

e=t:option(Value,"ipaddr",translate("IP Address"))
e.width="40%"
e.datatype="ip4addr"
e.placeholder="0.0.0.0/0"
luci.ip.neighbors({ family = 4 }, function(entry)
	if entry.reachable then
		e:value(entry.dest:string())
	end
end)

e=t:option(ListValue,"filter_mode",translate("Filter Mode"))
e.width="40%"
e.default="disable"
e.rmempty=false
e:value("disable",translate("No filter"))
e:value("global",translate("Global filter"))

return m