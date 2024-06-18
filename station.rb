ref = []
File.open('../station_database/src/station.csv', 'r:utf-8') do |file|
  file.each_line do |line|
    next if line.start_with? 'code'

    cols = line.split ','
    next if cols[13].to_i == 1

    ref << {
      'code' => cols[0].to_i,
      'name' => cols[2],
      'original_name' => cols[3],
      'pref' => cols[7].to_i
    }
  end
end

data = []
File.open('static/map/data/stations.csv', 'r:utf-8') do |file|
  file.each_line do |line|
    next if line.start_with? 'cd'

    cols = line.split ','
    data << {
      'code' => cols[0].to_i,
      'name' => cols[1],
      'lat' => cols[2], # 小数点以下桁数が揃っていないので文字列のまま扱う
      'lng' => cols[3],
      'pref' => cols[4].to_i,
      'prefname' => cols[5],
      'type' => cols[6].to_i
    }
  end
end

prefecture = []
File.open('static/map/data/prefs_ekimemo.csv', 'r:utf-8') do |file|
  file.each_line do |line|
    next if line.start_with? 'pref'

    cols = line.split ','
    prefecture << {
      'code' => cols[0].to_i,
      'name' => cols[1],
      'count' => cols[4].to_i
    }
  end
end

data.dup.each do |s2|
  next if ref.index { |s1| s1['name'] == s2['name'] }

  i = ref.index { |s1| s1['original_name'] == s2['name'] && s1['code'] == s2['code'] }

  if i
    s2['name'] = ref[i]['name']
  else
    puts "enter suffix for #{s2}"
    suffix = gets.chomp
    raise 'no input' if !suffix || suffix.empty?

    name = "#{s2['name']}(#{suffix})"
    raise "not found for #{name}" unless ref.index { |s1| s1['name'] == name }

    s2['name'] = name
  end

  File.open('static/map/data/stations.csv', 'w:utf-8') do |file|
    file.puts 'cd,name,lat,lng,prefcd,prefname,type'
    data.each do |f|
      line = format(
        '%d,%s,%s,%s,%02d,%s,%d',
        f['code'],
        f['name'],
        f['lat'],
        f['lng'],
        f['pref'],
        f['prefname'],
        f['type']
      )
      file.puts line
    end
  end
end
