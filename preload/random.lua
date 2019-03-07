
function get_random_int(mix,max)
	return math.random(mix,max)
end

function get_random_value_in_weight(total_weight, value_weight_list)
	if total_weight == 0 or #value_weight_list == 0 then return end
	local random_weight = get_random_int(1,total_weight)
	for i,value in pairs(value_weight_list) do
		if value[2] < random_weight then
			random_weight = random_weight - value[2]
		else
			return value[1]
		end
	end
	return nil
end

function deep_copy_table(src_tbl,des_tbl)
	for key,value in pairs(src_tbl) do
		if type(value) == "table" then
			des_tbl[key] = {}
			utils.deep_copy_table(value,des_tbl[key])
		else
			des_tbl[key] = value
		end
	end
end

function get_random_list_in_weight(total_weight,value_weight_list,count)
	if total_weight == 0 or #value_weight_list == 0 then return end
	local result = {}
	if #value_weight_list <= count then
		for k,v in pairs(value_weight_list) do
			local value = v[1]
			table.insert( result,value)
		end
		return result
	end
	local copy_value_weight_list = copy(value_weight_list)
	for i=1,count do
		local random_weight = get_random_int(1,total_weight)
		for i,value in pairs(copy_value_weight_list) do
			if value[2] < random_weight then
				random_weight = random_weight - value[2]
			else
				table.insert(result,value[1])
				total_weight = total_weight - value[2]
				value_weight_list[i] = nil
				break
			end
		end
	end
	return result
end

function get_interval_timestamp(timestamp)
	local temp = os.date("*t", timestamp)
	return os.time{year=temp.year, month=temp.month, day=temp.day, hour=23} + 60 * 60
end
