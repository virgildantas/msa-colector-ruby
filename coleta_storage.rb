require 'net/ssh'
require 'json'
require 'active_support/json'
require 'active_support/core_ext'
###### Conceitos/Concepts ###########
#script para acessar as controladoras de storages dos tipo MSA 
# via terminal e coletar informações de IO de todos os volumes, 
# após isto, registra essas informações em arquivos com o nome
# dos próprios volumes para o monitoramento poder coletar.
###
#script to access MSA type storage controllers
# via terminal and collect IO information from all volumes,
# after that, record this information in files with the name
# of the volumes themselves for monitoring to be able to collect.
###### Conceitos/Concepts ###########

  host_msa1 = "IP Address 02"
  host_msa2 = "IP Address 02"
  user = "username"
  senha = "password"

while true

##lendo dados MSA1
##reading MSA1 informations
session=Net::SSH.start(host_msa1, user, :password => senha)

dados_xml = (session.exec! "show volume-statistics")
d = dados_xml
d = d.gsub("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>","")
d = d.gsub("#","")
d = d.gsub(" show volume-statistics","")
json = Hash.from_xml(d).to_json
dados = JSON.parse(json, object_class: OpenStruct)
session.close

total = 0
total_storage = 0
dados.RESPONSE.OBJECT.each do |p|
      file = File.open("#{p.PROPERTY[0]}_io.txt", "w")
      file.puts "#{p.PROPERTY[4]}"
      file.close
      total = total + p.PROPERTY[4].to_i ##somando IO total
    end

file = File.open("total_MSA1_io.txt", "w")
      file.puts "#{total}"
      file.close
total_storage = total
## FIM lendo dados MSA1
## END reading MSA1 informations



##Se tiver apenas uma controladora pode deletar esta parte do código separada para a MSA2 ou multiplicar ela se tiver mais
##If you have only one controller you can delete this part of the code separately for MSA2 or multiply it if you have more
##lendo dados MSA2
##reading MSA2 informations
session=Net::SSH.start(host_msa2, user, :password => senha)

dados_xml = (session.exec! "show volume-statistics")
d = dados_xml 
d = d.gsub("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>","")
d = d.gsub("#","")
d = d.gsub(" show volume-statistics","")
json = Hash.from_xml(d).to_json
dados = JSON.parse(json, object_class: OpenStruct)
session.close
#puts dados.RESPONSE.OBJECT[2].PROPERTY[0]+ " -> " + dados.RESPONSE.OBJECT[2].PROPERTY[4] 
total = 0
dados.RESPONSE.OBJECT.each do |p| 
      file = File.open("#{p.PROPERTY[0]}_io.txt", "w")
      file.puts "#{p.PROPERTY[4]}"
      file.close
      total = total + p.PROPERTY[4].to_i ##somando IO total
    end

file = File.open("total_MSA2_io.txt", "w")
      file.puts "#{total}"
      file.close
total_storage = total + total_storage

## FIM lendo dados MSA2
## END reading MSA2 informations


#gravando total de IO nas duas storages
#writing all of IO on all storage controllers
file = File.open("total_io.txt", "w")
      file.puts "#{total_storage}"
      file.close


end
