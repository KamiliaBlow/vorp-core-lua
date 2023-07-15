TriggerEvent("getCore",function(core)
    VorpCore = core
end)

----------------------------------------GET NAME---------------------------------------------------

RegisterServerEvent("vorp_rbm:first_last")
AddEventHandler("vorp_rbm:first_last", function(target, id) 
	local _source = source
	local User = VorpCore.getUser(target)
	if User  == nil then
		return '?'
	end
	local Character = User.getUsedCharacter 
	local first = Character.firstname
	local last = Character.lastname

	if (first == nil or last == nil) then
		return '?'
	end

	Citizen.Wait(500)
	--print("first last: "..tostring(first).." "..tostring(last))
	--print("ID: "..tostring(id))
	TriggerClientEvent("first_last_tar", _source, first.." "..last, id)
end)