require '/work/gi/coop/perner/metameta/scripts/paths'

vent_arr = ['abe','kilo moana','mariner','tahi moana','tui malila','hulk',
            'anemone','dependable','el guapo','marker113','marker33','marshmallow',
            'n3','beebe','von damm','trollveggen','guaymas basin','fryer','sisters peak',"loki's castle",'kueishantao','4143-1']

  File.open("#{Paths.data}/vent_fields_interridge.csv").each_line do |line|
    l = line.split(",")
    name_id = l[0]
    name_aliases = l[1]     
    feature_id = l[2]
    vent_site = l[3]
    vent_arr.each do |vent|
      match = `grep -wi #{vent} < (echo #{l[0]})`
      puts l[0] if match != nil
    end


  end







