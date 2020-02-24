require 'csv'

#функция которая возвращает
def openallfile()
  result={'price' => CSV.read('./data/02_ruby_prices.csv'),'vms' =>CSV.read('./data/02_ruby_vms.csv'),'volume' =>CSV.read('./data/02_ruby_volumes.csv'),}
  result['price'].map!{|elem| [elem[0],elem[1].to_i]}
  result['vms'].map!{|elem| [elem[0].to_i,elem[1].to_i,elem[2].to_i,elem[3],elem[4].to_i]}
  result['volume'].map!{|elem| [elem[0].to_i,elem[1],elem[2].to_i,]}
  result
end

#функция возврата всех доп дисков[типа,объема] для заданной машины
def allhdd(arraydata,id)
  arraydata['volume'].filter_map{|elem| [elem[1],elem[2]] if elem[0]==id }
end

#цена заданной машины
def pricevm(arraydata,vm)

  v= arraydata['price'].filter_map { |elem| elem[1] if elem[0]=='cpu' }
  price=vm[1]*arraydata['price'].filter_map { |elem| elem[1] if elem[0]=='cpu' }[0] +vm[2]*arraydata['price'].filter_map { |elem| elem[1] if elem[0]=='ram' }[0] +vm[4]*arraydata['price'].filter_map { |elem| elem[1] if elem[0]==vm[3] }[0]
  allhdd(arraydata,vm[0]).each{|elem| price+=elem[1]*arraydata['price'].filter_map { |elem2| elem2[1] if elem2[0]==elem[0] }[0]}
  price
end


#вернем массив машин с их ценами в виде [id, цена]
def priceallvm(arraydata)
  # help=[]
  arraydata['vms']
      .map{|elem| [elem[0],pricevm(arraydata,elem)]}
end


#отчет первый n самых дорогих машин
def highprice(arraydata,n)
  priceallvm(arraydata)
      .sort_by { |elem | -elem[1] }
      .slice(0,n)
      .map{|elem| elem[0]}
end
# отчет второй n самых дешевых машин
def lowprice(arraydata,n)
  priceallvm(arraydata).sort_by { |elem | elem[1] }.slice(0,n).map{|elem| elem[0]}
  # allprice=priceallvm(arraydata)
  # result=[]
  # while n>0 and allprice.size
  #   now=allprice.min_by{|i| i[1]}
  #   result.append(now)
  #   allprice.slice(now)
  #   n=-1
  # end

end

#отчет третий Отчет который выводит n самых объемных ВМ по параметру type
def volumebytype(arraydata,type,n)
  result=[]
  case type
  when 'cpu'
    arraydata['vms'].sort_by { |elem| -elem[1] }.slice(0,n).map{|elem| elem[0]}
  when 'ram'
    arraydata['vms'].sort_by { |elem| -elem[2] }.slice(0,n).map{|elem| elem[0]}
  when 'ssd'
    result=arraydata['vms'].map{|elem|  elem[3]=='ssd' ? [elem[0],elem[4]] : [elem[0],0]  }
    result.map!{|elem| [elem[0],elem[1]+allhdd(arraydata,elem[0]).filter_map{|elem2| elem2[1] if elem2[0]=='ssd'}.sum()]}
    # arraydata[1].each{|elem| result.append([elem[0],allhdd(arraydata,elem[0]).map{|elem| return elem[1] if elem[0]=='ssd'} ]) if allhdd(arraydata,elem[0]).map{|elem| elem[0]}.include?'ssd' }
    result.sort_by{|elem| -elem[1]}.slice(0,n).map{|elem| elem[0]}
  when 'sata'
    #таким болжен быть ли объем жесткого диска или он должен быть среди дополнительных
    result=arraydata['vms'].map{|elem|  elem[3]=='sata' ? [elem[0],elem[4]] : [elem[0],0]  }
    result.map!{|elem| [elem[0],elem[1]+allhdd(arraydata,elem[0]).filter_map{|elem2| elem2[1] if elem2[0]=='sata'}.sum()]}
    # arraydata[1].each{|elem| result.append([elem[0],allhdd(arraydata,elem[0]).map{|elem| return elem[1] if elem[0]=='ssd'} ]) if allhdd(arraydata,elem[0]).map{|elem| elem[0]}.include?'ssd' }
    result.sort_by{|elem| -elem[1]}.slice(0,n).map{|elem| elem[0]}
  when 'sas'
    #таким болжен быть ли объем жесткого диска или он должен быть среди дополнительных
    result=arraydata['vms'].map{|elem|  elem[3]=='sata' ? [elem[0],elem[4]] : [elem[0],0]  }
    result.map!{|elem| [elem[0],elem[1]+allhdd(arraydata,elem[0]).filter_map{|elem2| elem2[1] if elem2[0]=='sata'}.sum()]}
    # arraydata[1].each{|elem| result.append([elem[0],allhdd(arraydata,elem[0]).map{|elem| return elem[1] if elem[0]=='ssd'} ]) if allhdd(arraydata,elem[0]).map{|elem| elem[0]}.include?'ssd' }
    result.sort_by{|elem| -elem[1]}.slice(0,n).map{|elem| elem[0]}
  end
end



#отчет четвернтый -Отчет который выводит n ВМ
# у которых подключено больше всего дополнительных дисков (по количеству)
# (с учетом типа диска если параметр hdd_type указан)
def quantityadditionaldrives(arraydata,n,hdd_type=nil )
  if hdd_type
    arraydata['vms'].map{|elem| [elem[0],allhdd(arraydata,elem[0]).filter_map{|elem| elem if elem[0]==hdd_type}.size]}
        .sort_by { |elem | elem[1] }
        .slice(0,n)
        .map{|elem| elem[0]}
  else
  arraydata['vms'].map{|elem| [elem[0],allhdd(arraydata,elem[0]).size]}.sort_by { |elem | -elem[1] }
      .slice(0,n)
      .map{|elem| elem[0]}
  end
end

#отчет пятый - Отчет который выводит n ВМ
# у которых подключено больше всего дополнительных дисков (по объему)
# (с учетом типа диска если параметр hdd_type указан)
def volumeadditionaldrives(arraydata,n,hdd_type=nil )
  if hdd_type
    arraydata['vms'].map{|elem| [elem[0],allhdd(arraydata,elem[0]).filter_map{|elem| elem[1] if elem[0]==hdd_type}.sum()]}
        .sort_by { |elem | elem[1] }
        .slice(0,n)
        .map{|elem| elem[0]}
  else
    arraydata['vms'].map{|elem| [elem[0],allhdd(arraydata,elem[0]).filter_map{|elem| elem[1]}.sum()]}.sort_by { |elem | elem[1] }
        .slice(0,n)
        .map{|elem| elem[0]}
  end
end

def wantputsallreports()
  arraydata=openallfile()
  puts 'Введите число n'
  n=STDIN.gets.to_i
  # n=6
  puts "отчет первый #{n} самых дорогих машин:"
  puts highprice(arraydata,n)
  puts "отчет второй #{n} самых дешевых машин:"
  puts lowprice(arraydata,n)
  puts 'Введите type для третьего отчета'
  type=STDIN.gets.chomp
  # type2='cpu'
  puts "отчет третий #{n} самых объемных ВМ по параметру #{type}:"
  puts volumebytype(arraydata,type,n)
  puts "отчет четвертый(без доп аргумента) #{n} ВМ у которых подключено больше всего дополнительных дисков (по количеству):"
  puts quantityadditionaldrives(arraydata,n)
  puts "отчет пятый(без доп аргумента) #{n} ВМ у которых подключено больше всего дополнительных дисков (по объему):"
  puts volumeadditionaldrives(arraydata,n)
  #
  puts 'Введите hdd_type для 4 и 5 отчета'
  hdd_type=STDIN.gets.chomp
  # # hdd_type='sas'
  puts "отчет четвертый(с доп аргументом) #{n} ВМ у которых подключено больше всего дополнительных дисков (по количеству):"
  puts quantityadditionaldrives(arraydata,n,hdd_type)
  puts "отчет пятый(с доп аргументом) #{n} ВМ у которых подключено больше всего дополнительных дисков (по объему):"
  puts volumeadditionaldrives(arraydata,n,hdd_type)
end

wantputsallreports()