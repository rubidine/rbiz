module CartHelper

  def state_select obj, meth
     rv = <<-EOF
    <select name="#{obj}[#{meth}]" id="#{obj}_#{meth}">
      <option></option>
      <optgroup label="United States">
        <option id="USA-AL" value="USA-AL">Alabama (AL)</option>
        <option id="USA-AK" value="USA-AK">Alaska (AK)</option>
        <option id="USA-AZ" value="USA-AZ">Arizona (AZ)</option>
        <option id="USA-AR" value="USA-AR">Arkansas (AR)</option>             
        <option id="USA-CA" value="USA-CA">California (CA)</option>
        <option id="USA-CO" value="USA-CO">Colorado (CO)</option>
        <option id="USA-CT" value="USA-CT">Connecticut (CT)</option>
        <option id="USA-DE" value="USA-DE">Delaware (DE)</option>
        <option id="USA-DC" value="USA-DC">District of Columbia (DC)</option> 
        <option id="USA-FL" value="USA-FL">Florida (FL)</option>
        <option id="USA-GA" value="USA-GA">Georgia (GA)</option>
        <option id="USA-GU" value="USA-GU">Guam (GU)</option>
        <option id="USA-HI" value="USA-HI">Hawaii (HI)</option>
        <option id="USA-ID" value="USA-ID">Idaho (ID)</option>
        <option id="USA-IL" value="USA-IL">Illinois (IL)</option>
        <option id="USA-IN" value="USA-IN">Indiana (IN)</option>
        <option id="USA-IA" value="USA-IA">Iowa (IA)</option>
        <option id="USA-KS" value="USA-KS">Kansas (KS)</option>
        <option id="USA-KY" value="USA-KY">Kentucky (KY)</option>
        <option id="USA-LA" value="USA-LA">Louisiana (LA)</option>
        <option id="USA-ME" value="USA-ME">Maine (ME)</option>
        <option id="USA-MD" value="USA-MD">Maryland (MD)</option>
        <option id="USA-MA" value="USA-MA">Massachusetts (MA)</option>
        <option id="USA-MI" value="USA-MI">Michigan (MI)</option>
        <option id="USA-MN" value="USA-MN">Minnesota (MN)</option>
        <option id="USA-MS" value="USA-MS">Mississippi (MS)</option>
        <option id="USA-MO" value="USA-MO">Missouri (MO)</option>
        <option id="USA-MT" value="USA-MT">Montana (MT)</option>
        <option id="USA-NE" value="USA-NE">Nebraska (NE)</option>
        <option id="USA-NE" value="USA-NE">Nebraska (NE)</option>
        <option id="USA-NE" value="USA-NE">Nebraska (NE)</option>
        <option id="USA-NV" value="USA-NV">Nevada (NV)</option>
        <option id="USA-NH" value="USA-NH">New Hampshire (NH)</option>
        <option id="USA-NJ" value="USA-NJ">New Jersey (NJ)</option>
        <option id="USA-NM" value="USA-NM">New Mexico (NM)</option>
        <option id="USA-NY" value="USA-NY">New York (NY)</option>
        <option id="USA-NC" value="USA-NC">North Carolina (NC)</option>
        <option id="USA-ND" value="USA-ND">North Dakota (ND)</option>
        <option id="USA-OH" value="USA-OH">Ohio (OH)</option>
        <option id="USA-OK" value="USA-OK">Oklahoma (OK)</option>
        <option id="USA-OR" value="USA-OR">Oregon (OR)</option>
        <option id="USA-PA" value="USA-PA">Pennyslvania (PA)</option>
        <option id="USA-PR" value="USA-PR">Puerto Rico (PR)</option>
        <option id="USA-RI" value="USA-RI">Rhode Island (RI)</option>
        <option id="USA-SC" value="USA-SC">South Carolina (SC)</option>
        <option id="USA-SD" value="USA-SD">South Dakota (SD)</option>
        <option id="USA-TN" value="USA-TN">Tennessee (TN)</option>
        <option id="USA-TX" value="USA-TX">Texas (TX)</option>
        <option id="USA-UT" value="USA-UT">Utah (UT)</option>
        <option id="USA-VT" value="USA-VT">Vermont (VT)</option>
        <option id="USA-VA" value="USA-VA">Virginia (VA)</option>
        <option id="USA-VI" value="USA-VI">Virgin Islands (VI)</option>
        <option id="USA-WA" value="USA-WA">Washington (WA)</option>
        <option id="USA-WV" value="USA-WV">West Virginia (WV)</option>
        <option id="USA-WI" value="USA-WI">Wisconsin (WI)</option>
        <option id="USA-WY" value="USA-WY">Wyoming (WY)</option>
      </optgroup>
    EOF
    if CartConfig.get(:ship_to_canada, :payment)
      rv +=  <<-EOF
        <optgroup label="Canada">
          <option id="CA-AB" value="CA-AB">Alberta (AB)</option>
          <option id="CA-BC" value="CA-BC">British Columbia (BC)</option>
          <option id="CA-MB" value="CA-MB">Manitoba (MB)</option>
          <option id="CA-NB" value="CA-NB">New Brunswick (NB)</option>
          <option id="CA-NL" value="CA-NL">Newfoundland and Labrador (NL)</option>
          <option id="CA-NT" value="CA-NT">Northwest Territories (NT)</option>
          <option id="CA-NS" value="CA-NS">Nova Scotia (NS)</option>
          <option id="CA-NU" value="CA-NU">Nunavut (NU)</option>
          <option id="CA-PE" value="CA-PE">Prince Edward Island (PE)</option>
          <option id="CA-SK" value="CA-SK">Saskatchewan (SK)</option>
          <option id="CA-ON" value="CA-ON">Ontario (ON)</option>
          <option id="CA-QC" value="CA-QC">Quebec (QC)</option>
          <option id="CA-YT" value="CA-YT">Yukon (YT)</option>
        </optgroup>
      EOF
    end
    if CartConfig.get(:ship_to_mexico, :payment)
      rv += <<-EOF
        <optgroup label="Mexico">
          <option id="MX-AGU" value="MX-AGU">Aguascalientes (AGU)</option>
          <option id="MX-BCN" value="MX-BCN">Baja California (BCN)</option>
          <option id="MX-BCS" value="MX-BCS">Baja California Sur (BCS)</option>
          <option id="MX-CAM" value="MX-CAM">Campeche (CAM)</option>
          <option id="MX-CHP" value="MX-CHP">Chiapas (CHP)</option>
          <option id="MX-CHH" value="MX-CHH">Chihuahua (CHH)</option>
          <option id="MX-COA" value="MX-COA">Coahuila (COA)</option>
          <option id="MX-COL" value="MX-COL">Colima (COL)</option>
          <option id="MX-DUR" value="MX-DUR">Durango (DUR)</option>
          <option id="MX-GUA" value="MX-GUA">Guanajuato (GUA)</option>
          <option id="MX-GRO" value="MX-GRO">Guerrero (GRO)</option>
          <option id="MX-HID" value="MX-HID">Hidalgo (HID)</option>
          <option id="MX-JAL" value="MX-JAL">Jalisco (JAL)</option>
          <option id="MX-MEX" value="MX-MEX">Mexico State (MEX)</option>
          <option id="MX-MIC" value="MX-MIC">Michoacán (MIC)</option>
          <option id="MX-MOR" value="MX-MOR">Morelos (MOR)</option>
          <option id="MX-NAY" value="MX-NAY">Nayarit (NAY)</option>
          <option id="MX-NLE" value="MX-NLE">Nuevo León (NLE)</option>
          <option id="MX-OAX" value="MX-OAX">Oaxaca (OAX)</option>
          <option id="MX-PUE" value="MX-PUE">Puebla (PUE)</option>
          <option id="MX-QUE" value="MX-QUE">Querétaro (QUE)</option>
          <option id="MX-ROO" value="MX-ROO">Quintana Roo (ROO)</option>
          <option id="MX-SLP" value="MX-SLP">San Luis Potosí (SLP)</option>
          <option id="MX-SIN" value="MX-SIN">Sinaloa (SIN)</option>
          <option id="MX-SON" value="MX-SON">Sonora (SON)</option>
          <option id="MX-TAB" value="MX-TAB">Tabasco (TAB)</option>
          <option id="MX-TAM" value="MX-TAM">Tamaulipas (TAM)</option>
          <option id="MX-TLA" value="MX-TLA">Tlaxcala (TLA)</option>
          <option id="MX-VER" value="MX-VER">Veracruz (VER)</option>
          <option id="MX-YUC" value="MX-YUC">Yucatán (YUC)</option>
          <option id="MX-ZAC" value="MX-ZAC">Zacatecas (ZAC)</option>
        </optgroup>
      EOF
    end
    rv += '</select>'
    rv
  end

end
