StackOverflow R: Creating a SAS dataset from a javascript generated web table(without a browser)

  I am not a web master so some of this may not be exactly right.

  It is much harder extract the json formatted data behind a browser rendered table then direct HTML tables.
  You don't have a browser so you may need a javascript engine and a html reader.
  Browsers automatically render javascript and html, so you never see the server code?

     WORKING CODE


         Need to use browser 'view source' to get key tokens

         <div id="indicadores_financieros_wrapper">
                  -----need this text------------

         Then you need to locate the javascript generated data created from json data
                 var valor =  * Javascript variable?;
                     -----

         Now you can write the code

         banorte <- "https://www.banorte.com/wps/portal/ixe/Home/indicadores/tipo-de-cambio/" %>%
               read_html() %>%    * HAS IMBEDED JAVASCRIPT?;
               html_nodes("#indicadores_financieros_wrapper > script:nth-child(2)");

         ctx <- v8();  * JAVASCRIPT ENGINE;

         html_text(banorte) %>%
           stri_split_lines() %>%
           flatten_chr() %>%
           keep(stri_detect_regex, "^\tvar") %>%
           ctx$eval();  * EXECUTE JAVASCRIPT;

         jsonlite::fromJSON(ctx$get("valor"));

see
https://goo.gl/gkTb2M
https://stackoverflow.com/questions/46823199/scraping-a-javascript-object-and-converting-to-json-within-r-rvest

hrbrmstr profile
https://stackoverflow.com/users/1457051/hrbrmstr


HAVE
====

   https://www.banorte.com/wps/portal/ixe/Home/indicadores/tipo-de-cambio/

   Here is what the Chrome rendered page looks like

   INICIO INDICADORESTIPO DE CAMBIO

   DÓLARES Y DIVISAS

   Dólares           Compra      Venta
   VENTANILLA        $17.65      $19.05

   Divisas           Compra      Venta
   FRANCO SUIZO      $18.80      $19.65
   LIBRA ESTERLINA   $24.22      $25.15
   YEN JAPONES       $0.164      $0.172
   CORONA SUECA      $2.15       $2.50
   DOLAR CANADA      $14.55      $15.40
   EURO              $21.75

   * This is the JavaScript, as an XML nodeset rendered by browser behind the page;

   <div id="indicadores_financieros_wrapper">
   <xxxscript src="https://www.banorte.com/wps/PA_IadoresFinancieros/_IndicadoresFinancieros
         /js/indicadores_responsive.js;wa40ba6b1d5f452e03"></script>
   <xxxscript>
   $(document).ready(function(){
         var valor = '{"tablaDivisas":[{"nombreDivisas":"FRANCO SUIZO","compra":"18.80","venta":"19.65"},
         {"nombreDivisas":"LIBRA ESTERLINA","compra":"24.22","venta":"25.15"},{"nombreDivisas":"YEN JAPONES",
         "compra":"0.1645","venta":"0.172"},{"nombreDivisas":"CORONA SUECA","compra":"2.15","venta":"2.50"},
         {"nombreDivisas":"DOLAR CANADA","compra":"14.55","venta":"15.40"},{"nombreDivisas":
         "EURO","compra":"21.75","venta":"22.60"}],"tablaDolar":[{"nombreDolar":"VENTANILLA","compra":"17.65","venta":"19.05"}]}';
         if(valor != '{}'){
               var objJSON = eval("(" + valor + ")");
               var      tabla="<tbody>";
               for ( var i = 0; i < objJSON["tablaDolar"].length; i++) {
                     tabla+= "<tr>";
                     tabla+= "<td>" + objJSON["tablaDolar"][i].nombreDolar + "</td>";
                     tabla+= "<td>$" + objJSON["tablaDolar"][i].compra + "</td>";
                     tabla+= "<td>$" + objJSON["tablaDolar"][i].venta + "</td>";
                     tabla+= "</tr>";
               }
               tabla+= "</tbody>";
               $("#tablaDolar").append(tabla);
               var tabla2="";
               for ( var i = 0; i < objJSON["tablaDivisas"].length; i++) {
                     tabla2+= "<tr>";
                     tabla2+= "<td>" + objJSON["tablaDivisas"][i].nombreDivisas + "</td>";
                     tabla2+= "<td>$" + objJSON["tablaDivisas"][i].compra + "</td>";
                     tabla2+= "<td>$" + objJSON["tablaDivisas"][i].venta + "</td>";
                     tabla2+= "</tr>";
               }
               tabla2+= "</tbody>";
               $("#tablaDivisas").append(tabla2);
         }
         bmnIndicadoresResponsivoInstance.cloneResponsive(0);
   });
   </xxxscript>


   This is closer to what exists on the server? JavaScript?

   banorte <- "https://www.banorte.com/wps/portal/ixe/Home/indicadores/tipo-de-cambio/" %>%
         read_html() %>%
         html_nodes("#indicadores_financieros_wrapper > script:nth-child(2)");

   [1] "\r\n$(document).ready(function(){\r\n\tva...
   ":\"LIBRA ESTERLINA\",\"compra\":\"24.22\",\"v...
   UECA\",\"compra\":\"2.15\",\"venta\":\"2.50\"}...
   \",\"venta\":\"22.60\"}],\"tablaDolar\":[{\"no...
   (\" + valor + \")\");\r\n\t\tvar\ttabla=\"<tbo...
   " + objJSON[\"tablaDolar\"][i].nombreDolar + \...
   tablaDolar\"][i].venta + \"</td>\";\r\n\t\t\tt...
   t\tfor ( var i = 0; i < objJSON[\"tablaDivisas...
   td>\";\r\n\t\t\ttabla2+= \"<td>$\" + objJSON[\..
   \ttabla2+= \"</tr>\";\r\n\t\t}\r\n\t\ttabla2+=..
   \n});\r\n"


WANT  (SAS dataset)
===

  WORK.WANT_WPS total obs=6

         TABLADIVISAS_      TABLADIVISAS_    TABLADIVISAS_    TABLADOLAR_    TABLADOLAR_    TABLADOLAR_
  Obs    NOMBREDIVISAS         COMPRA            VENTA        NOMBREDOLAR      COMPRA          VENTA

   1     FRANCO SUIZO          18.80             19.65        VENTANILLA        17.65          19.05
   2     LIBRA ESTERLINA       24.22             25.15        VENTANILLA        17.65          19.05
   3     YEN JAPONES           0.1645            0.172        VENTANILLA        17.65          19.05
   4     CORONA SUECA          2.15              2.50         VENTANILLA        17.65          19.05
   5     DOLAR CANADA          14.55             15.40        VENTANILLA        17.65          19.05
   6     EURO                  21.75             22.60        VENTANILLA        17.65          19.05


*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

   https://www.banorte.com/wps/portal/ixe/Home/indicadores/tipo-de-cambio/


 *          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_submit_wps64('
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(rvest);
library(stringi);
library(V8);
library(tidyverse);
banorte <- "https://www.banorte.com/wps/portal/ixe/Home/indicadores/tipo-de-cambio/" %>%
      read_html() %>%
      html_nodes("#indicadores_financieros_wrapper > script:nth-child(2)");
ctx <- v8();
html_text(banorte) %>%
  stri_split_lines() %>%
  flatten_chr() %>%
  keep(stri_detect_regex, "^\tvar") %>%
  ctx$eval();
want<-jsonlite::fromJSON(ctx$get("valor"));
endsubmit;
import r=want  data=wrk.want_wps;
run;quit;
');


> source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
> .libPaths(c(.libPaths(), "d:/3.3.2", "d:/3.3.2_usr"))
> options(help_type = "html")
> library(rvest);
> library(stringi);
> library(V8);
> library(tidyverse);
> banorte <- "https://www.banorte.com/wps/portal/ixe/Home/indicadores/tipo-de-cambio/" %>%
      read_html() %>%
      html_nodes("#indicadores_financieros_wrapper > script:nth-child(2)");
> ctx <- v8();
> html_text(banorte) %>%  stri_split_lines() %>%  flatten_chr() %>%  keep(stri_detect_regex, "^\tvar") %>%  ctx$eval();
> want<-jsonlite::fromJSON(ctx$get("valor"));

NOTE: Processing of R statements complete

15        import r=want  data=wrk.want_wps;
NOTE: Creating data set 'WRK.want_wps' from R data frame 'want'
NOTE: Column names modified during import of 'want'
NOTE: Data set "WRK.want_wps" has 6 observation(s) and 6 variable(s)

16        run;
NOTE: Procedure r step took :
      real time : 3.918
      cpu time  : 0.015
17        quit;

NOTE: Submitted statements took :
      real time : 3.951
      cpu time  : 0.031


