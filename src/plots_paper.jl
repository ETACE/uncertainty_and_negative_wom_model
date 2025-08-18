using Serialization
using Plots,TensorCast
using DataStructures
using StatsPlots

include("model/model.jl")

const PLOTS_FOLDER = "../plots/paper/"

function main()
	mkpath(PLOTS_FOLDER)

	# Figure 1
	baseline_overview()

	# Figure 2 (a)-(c)
	empirical_population()

	# Figure 2 (d)-(e)
	cosita_mixed_with_bayes_goldenberg()

	# Figure 3
	networks()
end

function baseline_overview()
	data1 = load_data("config/monopoly_goldenberg.jl")
	series_goldenberg = get_data_exp_key(data1, "goldenberg", "adopters1")
	data2 = load_data("config/monopoly_bayes.jl")
	series_bayes = get_data_exp_key(data2, "bayes_normal", "adopters1")
	data3 = load_data("config/monopoly_cosita.jl")
	series_cosita = get_data_exp_key(data3, "cosita", "adopters1")

	extend_series!(series_goldenberg, 1001)

	pl = plot(title="")
	add_series_with_ribbon!(pl,1:1001,map(s->s[1:1001],series_goldenberg),"blue", "Goldenberg")
	add_series_with_ribbon!(pl,1:1001,map(s->s[1:1001],series_bayes),"green", "Bayes")
	add_series_with_ribbon!(pl,1:1001,map(s->s[1:1001],series_cosita),"orange", "CoSiTA")
	savefig(pl,"$PLOTS_FOLDER/monopoly_adopters_cut.pdf")

	pl = plot(title="", ylims=(0,12))
	add_series!(pl,1:1000,map(s->s[1:1000],[diff(s) for s in series_goldenberg]),"blue", "Goldenberg")
	add_series!(pl,1:1000,map(s->s[1:1000],[diff(s) for s in series_bayes]),"green", "Bayes")
	add_series!(pl,1:1000,map(s->s[1:1000],[diff(s) for s in series_cosita]),"orange", "CoSiTA")
	savefig(pl,"$PLOTS_FOLDER/monopoly_new_adopters_cut.pdf")

	end_cosita = [series[end] for series in series_cosita]
	end_bayes = [series[end] for series in series_bayes]
	end_goldenberg = [series[end] for series in series_goldenberg]

	pl = boxplot([end_goldenberg, end_bayes, end_cosita], label=["Goldenberg" "Bayes" "CoSiTA"], color=[:blue :green :orange], title="", xticks=false)
	savefig(pl,"$PLOTS_FOLDER/monopoly_final_adopters.pdf")

	series_goldenberg = get_data_exp_key(data1, "goldenberg", "rejecters1")
	series_bayes = get_data_exp_key(data2, "bayes_normal", "rejecters1")
	series_cosita = get_data_exp_key(data3, "cosita", "rejecters1")

	extend_series!(series_goldenberg, 1001)

	pl = plot(title="")
	add_series_with_ribbon!(pl,1:1001,map(s->s[1:1001],series_goldenberg),"blue", "Goldenberg")
	add_series_with_ribbon!(pl,1:1001,map(s->s[1:1001],series_bayes),"green", "Bayes")
	add_series_with_ribbon!(pl,1:1001,map(s->s[1:1001],series_cosita),"orange", "CoSiTA")
	savefig(pl,"$PLOTS_FOLDER/monopoly_rejecters_cut.pdf")

	series_goldenberg = get_data_exp_key(data1, "goldenberg", "undecided1")
	series_bayes = get_data_exp_key(data2, "bayes_normal", "undecided1")
	series_cosita = get_data_exp_key(data3, "cosita", "undecided1")

	extend_series!(series_goldenberg, 1001)

	pl = plot(title="")
	add_series_with_ribbon!(pl,1:1001,map(s->s[1:1001],series_goldenberg),"blue", "Goldenberg")
	add_series_with_ribbon!(pl,1:1001,map(s->s[1:1001],series_bayes),"green", "Bayes")
	add_series_with_ribbon!(pl,1:1001,map(s->s[1:1001],series_cosita),"orange", "CoSiTA")
	savefig(pl,"$PLOTS_FOLDER/monopoly_undecided_cut.pdf")
end

function empirical_population()
	T=1000

	data = load_data("config/monopoly_mixed_pop_emp.jl")
	series_emp = get_data_exp_key(data, "mixed_pop_emp", "adopters1")

	series_emp_goldenberg = get_data_exp_key(data, "mixed_pop_emp", "adopters1_goldenberg")
	series_emp_bayes = get_data_exp_key(data, "mixed_pop_emp", "adopters1_bayes")
	series_emp_cosita = get_data_exp_key(data, "mixed_pop_emp", "adopters1_cosita")

	data1 = load_data("config/monopoly_goldenberg.jl")
	series_goldenberg = get_data_exp_key(data1, "goldenberg", "adopters1")
	data2 = load_data("config/monopoly_bayes.jl")
	series_bayes = get_data_exp_key(data2, "bayes_normal", "adopters1")
	data3 = load_data("config/monopoly_cosita.jl")
	series_cosita = get_data_exp_key(data3, "cosita", "adopters1")

	series_weighted_mix = []

	extend_series!(series_goldenberg, 5000)
	extend_series!(series_bayes, 5000)
	extend_series!(series_cosita, 5000)

	g = 0.225
	b = 0.1625
	c = 0.6125

	for i in 1:100
		mix = g .* series_goldenberg[i] + g .* series_bayes[i] + c .* series_cosita[i]

		push!(series_weighted_mix, mix)
	end
	pl = plot(title="")
	add_series_with_ribbon!(pl,1:T,map(s->s[1:T],series_weighted_mix),"grey", "Weighted mix")
	add_series_with_ribbon!(pl,1:T,map(s->s[1:T],series_emp),"purple", "Empirical mix")
	savefig(pl,"$PLOTS_FOLDER/monopoly_emp_adopters.pdf")

	end_emp = [series[end] for series in series_emp]
	end_cosita = [series[end] for series in series_cosita]
	end_bayes = [series[end] for series in series_bayes]
	end_goldenberg = [series[end] for series in series_goldenberg]

	pl = boxplot([end_emp, end_goldenberg, end_bayes, end_cosita], label=["Emp. mix" "Goldenberg" "Bayes" "CoSiTA"], color=[:purple :blue :green :orange], title="", xticks=false)
	savefig(pl,"$PLOTS_FOLDER/monopoly_emp_vs_homo_final_adopters.pdf")

	end_cosita = [series[end] for series in series_emp_cosita]
	end_bayes = [series[end] for series in series_emp_bayes]
	end_goldenberg = [series[end] for series in series_emp_goldenberg]

	end_emp_pct = [series[end] / (3000) *100 for series in series_emp]
	end_cosita_pct = [series[end] / (3000*c) *100 for series in series_emp_cosita]
	end_bayes_pct = [series[end] / (3000*b) *100 for series in series_emp_bayes]
	end_goldenberg_pct = [series[end] / (3000*g) *100 for series in series_emp_goldenberg]

	pl = boxplot([end_emp_pct, end_goldenberg_pct, end_bayes_pct, end_cosita_pct], label=["Total" "Goldenberg" "Bayes" "CoSiTA"], color=[:purple :blue :green :orange], title="", xticks=false)
	savefig(pl,"$PLOTS_FOLDER/monopoly_emp_final_adopters_pct.pdf")
end

function cosita_mixed_with_bayes_goldenberg()
	data1 = load_data("config/monopoly_mixed_cosita_bayes.jl")
	data2 = load_data("config/monopoly_mixed_cosita_goldenberg.jl")

	T=1000
	c=0
	pl = plot(title="")
	add_series!(pl,1:T, get_data_exp_key(data1, "0.0", "adopters1", T), :black, "Bayes 0.0", linewidth=2)
	for z in 0.05:0.05:0.25
		c+=1
		add_series!(pl,1:T, get_data_exp_key(data1, "$z", "adopters1", T), palette(:default)[c], "Bayes $z")
	end
	savefig(pl,"$PLOTS_FOLDER/monopoly_cosita_vs_bayes.pdf")

	c=0
	pl = plot(title="")
	add_series!(pl,1:T, get_data_exp_key(data1, "0.0", "adopters1", T), :black, "Goldenberg 0.0", linewidth=2)
	for z in 0.05:0.05:0.25
		c+=1
		add_series!(pl,1:T, get_data_exp_key(data2, "$z", "adopters1", T), palette(:default)[c], "Goldenberg $z")
	end
	savefig(pl,"$PLOTS_FOLDER/monopoly_cosita_vs_goldenberg.pdf")
end

function networks()
	data = load_data("config/monopoly_ba.jl")
	series_goldenberg = get_data_exp_key(data, "goldenberg_ba", "adopters1")
	series_bayes = get_data_exp_key(data, "bayes_ba", "adopters1")
	series_cosita = get_data_exp_key(data, "cosita_ba", "adopters1")

	T=301
	pl = plot(title="")
	add_series_with_ribbon!(pl,1:T,map(s->s[1:T],series_goldenberg),"blue", "Goldenberg")
	add_series_with_ribbon!(pl,1:T,map(s->s[1:T],series_bayes),"green", "Bayes")
	add_series_with_ribbon!(pl,1:T,map(s->s[1:T],series_cosita),"orange", "CoSiTA")
	savefig(pl,"$PLOTS_FOLDER/monopoly_ba_adopters.pdf")

	data = load_data("config/monopoly_ws.jl")
	series_goldenberg = get_data_exp_key(data, "goldenberg_ws", "adopters1")
	series_bayes = get_data_exp_key(data, "bayes_ws", "adopters1")
	series_cosita = get_data_exp_key(data, "cosita_ws", "adopters1")

	T=301
	pl = plot(title="")
	add_series_with_ribbon!(pl,1:T,map(s->s[1:T],series_goldenberg),"blue", "Goldenberg")
	add_series_with_ribbon!(pl,1:T,map(s->s[1:T],series_bayes),"green", "Bayes")
	add_series_with_ribbon!(pl,1:T,map(s->s[1:T],series_cosita),"orange", "CoSiTA")
	savefig(pl,"$PLOTS_FOLDER/monopoly_ws_adopters.pdf")

	data = load_data("config/monopoly_er.jl")
	series_goldenberg = get_data_exp_key(data, "goldenberg_er", "adopters1")
	series_bayes = get_data_exp_key(data, "bayes_er", "adopters1")
	series_cosita = get_data_exp_key(data, "cosita_er", "adopters1")

	T=500
	pl = plot(title="")
	add_series_with_ribbon!(pl,1:T,map(s->s[1:T],series_goldenberg),"blue", "Goldenberg")
	add_series_with_ribbon!(pl,1:T,map(s->s[1:T],series_bayes),"green", "Bayes")
	add_series_with_ribbon!(pl,1:T,map(s->s[1:T],series_cosita),"orange", "CoSiTA")
	savefig(pl,"$PLOTS_FOLDER/monopoly_er_adopters.pdf")
end

function load_data(config)

	include(config)

	# load data
	results = []
	chunk = 0
	while isfile("$folder/data-$(chunk+=1).dat")
		append!(results, deserialize("$folder/data-$chunk.dat"))
	end

	if length(results) == 0
		println("ERROR: No data found in $folder/data/")
		exit(1)
	end

	data = Dict()

	for (exp_name, props) in experiments
		data[exp_name] = []

		for i in 1:length(results)
			if results[i][:exp_name] == exp_name
				append!(data[exp_name], [results[i][:model_data]])
			end
		end
	end

	return data
end

function get_data_exp_key(data, exp, key)
    data_exp_key = []
    for i in 1:length(data[exp])
        append!(data_exp_key, [data[exp][i][!, key]])
    end
    return data_exp_key
end

function get_data_exp_key(data, exp, key, limit)
	data_exp_key = get_data_exp_key(data, exp, key)

	return map(s->s[1:limit],data_exp_key)
end

function get_mean_upper_lower(data, conf_level=0.05)
    @cast data_t[i][j] := data[j][i]

	mean_data = []
	upper =[]
	lower = []

	for i in 1:length(data_t)
		append!(mean_data, mean(data_t[i]))
		if !isnan(mean(data_t[i]))
			append!(upper, quantile(data_t[i], 1-conf_level/2) - mean(data_t[i]))
			append!(lower, mean(data_t[i]) - quantile(data_t[i], conf_level/2))
		else
			append!(upper, NaN)
			append!(lower, NaN)
		end
	end

	return mean_data, upper, lower
end

function add_series!(pl, x, y, color, label; linestyle=:solid, linewidth=1)
	mean_data, upper, lower = get_mean_upper_lower(y)
	
	plot!(pl, x, mean_data, color=color, label=label, linewidth=linewidth, linestyle=linestyle)
end

function add_series_with_ribbon!(pl, x, y, color, label; linestyle=:solid, linewidth=1)
	mean_data, upper, lower = get_mean_upper_lower(y)
	
	plot!(pl, x, mean_data, color=color, label=label, linewidth=linewidth, ribbon = (lower, upper), linestyle=linestyle)
end

function extend_series!(series, n)
	for i in 1:length(series)
		if n - length(series[i]) > 0
			last_entry = series[i][end]
			series[i] = vcat(series[i], fill(last_entry, n - length(series[i])))
		end
	end
end

main()