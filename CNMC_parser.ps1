

function ParseaCNMCHTML ($pathSalidas){

    $pestanas=@("novedades","acuerdos-y-decisiones","informes")
    $fechaHoy=get-date -UFormat "%d%m%Y"
    add-content -Path ($pathSalidas + "log" + "_" + [string]$fechaHoy + ".csv") -value ("Pagina;Resultados_consulta;Resultados procesados")    

    foreach ($pestana in $pestanas){
        
        $fechato=get-date
        
        $fechatoFormateada=[string]$fechato.Day + "-" + [string]$fechato.Month + "-" + [string]$fechato.Year

        $fechafrom=$fechato.AddMonths(-6)
        $fechaFromFormateada=[string]$fechafrom.Day + "-" + [string]$fechafrom.Month + "-" + [string]$fechafrom.Year

        $url="https://www.cnmc.es/" + $pestana + "?s=&idambito=9&edit-submit-buscador-novedades=Aplicar&datefrom=" + $fechaFromFormateada + "&dateto=" + $fechatoFormateada +"&page=" + $contadorPaginas
        
        $html=Invoke-WebRequest -Uri $url
    
        $paginas=($html.AllElements|?{$_.class -eq "view-footer"})

        $contadorPaginas=([int]$paginas.innertext.Substring($paginas.innerText.Length-2,2))-1
        $numeroEntradas=$paginas.innertext.Substring(0,$paginas.innerText.IndexOf(" "))
        $numeroEntradasProcesadas=0
        
        while ($contadorPaginas -ge 0)  {
           
            
            $contadorPaginas
            $url="https://www.cnmc.es/" + $pestana + "?s=&idambito=9&edit-submit-buscador-novedades=Aplicar&datefrom=" + $fechaFromFormateada + "&dateto=" + $fechatoFormateada +"&page=" + $contadorPaginas
            
            $html=Invoke-WebRequest -Uri $url
            if ($pestana -eq "novedades"){
                $Fechas=($html.AllElements|?{$_."datetime"})
            }
            if ($pestana -eq "acuerdos-y-decisiones"){
                $Fechas=($html.AllElements|?{$_.class -eq "node__content"})
                
            }
            if ($pestana -eq "informes"){
                $Fechas=($html.AllElements|?{$_.innertext -match "(0?[1-9]|[12][0-9]|3[01])[\/\s](Ene|Feb|Mar|Abr|May|Jun|Jul|Ago|Sep|Oct|Nov|Dic)[/\\/\s](19|20)\d{2}" -and $_.class -eq "txt-5 blue-2"})
            }
            
            $notificaciones=($html.AllElements|?{$_.class -eq "h2 m-bott-15 txt-5 blue-2"})
        
            
            for($i= 0;$i -lt $fechas.Count;$i++){
                if($pestana -eq "novedades"){
                    add-content -path ($pathSalidas + $pestana + "-" + $fechaHoy +  ".csv") -value ($fechas.item($i).datetime + ";" + $notificaciones.Item($i).innertext)
                }
                if($pestana -eq "acuerdos-y-decisiones"){
                    add-content -path ($pathSalidas + $pestana + "-" + $fechaHoy + ".csv") -value ($fechas.item($i).innertext + ";" + $notificaciones.Item($i).innertext)
                }
                if ($pestana -eq "informes"){
                    add-content -path ($pathSalidas + $pestana + "-" + $fechaHoy + ".csv") -value ($fechas.item($i).innertext + ";" + $notificaciones.Item($i).innertext)
                }
                $numeroEntradasProcesadas++
            }
            $contadorPaginas--

        } 
        
        
        add-content -Path ($pathSalidas + "log" + "_" + [string]$fechaHoy + ".csv") -value ($pestana + ";" + [string]$numeroEntradas + ";" + [string]$numeroEntradasProcesadas )   
    }

       
}

#ParseaCNMCHTML d:\borrar\
ParseaCNMCHTML \\server\maptel II\REE\05_regulacion\entregas\Miguel\