TriggerEvent("getCore",function(core)
    VorpCore = core
end)

----------------------------------------GET NAME---------------------------------------------------

RegisterServerEvent("vorp_rbm:first_last")
AddEventHandler("vorp_rbm:first_last", function(target) 
	local _source = source
	local User = VorpCore.getUser(target) 
	local Character = User.getUsedCharacter 

	Citizen.Wait(500)
	TriggerClientEvent("first_last_tar", _source, Character.firstname.." "..Character.lastname)
end)