module CartHelper

  def state_select obj, meth
     rv = <<-EOF
    <select name="#{obj}[#{meth}]" id="#{obj}_#{meth}">
      <option></option>
      <optgroup label="United States">
        <option id="USA-AL" value="AL">Alabama (AL)</option>
        <option id="USA-AK" value="AK">Alaska (AK)</option>
        <option id="USA-AZ" value="AZ">Arizona (AZ)</option>
        <option id="USA-AR" value="AR">Arkansas (AR)</option>             
        <option id="USA-CA" value="CA">California (CA)</option>
        <option id="USA-CO" value="CO">Colorado (CO)</option>
        <option id="USA-CT" value="CT">Connecticut (CT)</option>
        <option id="USA-DE" value="DE">Delaware (DE)</option>
        <option id="USA-DC" value="DC">District of Columbia (DC)</option>    
        <option id="USA-FL" value="FL">Florida (FL)</option>
        <option id="USA-GA" value="GA">Georgia (GA)</option>
        <option id="USA-GU" value="GU">Guam (GU)</option>
        <option id="USA-HI" value="HI">Hawaii (HI)</option>
        <option id="USA-ID" value="ID">Idaho (ID)</option>
        <option id="USA-IL" value="IL">Illinois (IL)</option>
        <option id="USA-IN" value="IN">Indiana (IN)</option>
        <option id="USA-IA" value="IA">Iowa (IA)</option>
        <option id="USA-KS" value="KS">Kansas (KS)</option>
        <option id="USA-KY" value="KY">Kentucky (KY)</option>
        <option id="USA-LA" value="LA">Louisiana (LA)</option>
        <option id="USA-ME" value="ME">Maine (ME)</option>
        <option id="USA-MD" value="MD">Maryland (MD)</option>
        <option id="USA-MA" value="MA">Massachusetts (MA)</option>
        <option id="USA-MI" value="MI">Michigan (MI)</option>
        <option id="USA-MN" value="MN">Minnesota (MN)</option>
        <option id="USA-MS" value="MS">Mississippi (MS)</option>
        <option id="USA-MO" value="MO">Missouri (MO)</option>
        <option id="USA-MT" value="MT">Montana (MT)</option>
        <option id="USA-NE" value="NE">Nebraska (NE)</option>
        <option id="USA-NV" value="NV">Nevada (NV)</option>
        <option id="USA-NH" value="NH">New Hampshire (NH)</option>
        <option id="USA-NJ" value="NJ">New Jersey (NJ)</option>
        <option id="USA-NM" value="NM">New Mexico (NM)</option>
        <option id="USA-NY" value="NY">New York (NY)</option>
        <option id="USA-NC" value="NC">North Carolina (NC)</option>
        <option id="USA-ND" value="ND">North Dakota (ND)</option>
        <option id="USA-OH" value="OH">Ohio (OH)</option>
        <option id="USA-OK" value="OK">Oklahoma (OK)</option>
        <option id="USA-OR" value="OR">Oregon (OR)</option>
        <option id="USA-PA" value="PA">Pennyslvania (PA)</option>
        <option id="USA-PR" value="PR">Puerto Rico (PR)</option>
        <option id="USA-RI" value="RI">Rhode Island (RI)</option>
        <option id="USA-SC" value="SC">South Carolina (SC)</option>
        <option id="USA-SD" value="SD">South Dakota (SD)</option>
        <option id="USA-TN" value="TN">Tennessee (TN)</option>
        <option id="USA-TX" value="TX">Texas (TX)</option>
        <option id="USA-UT" value="UT">Utah (UT)</option>
        <option id="USA-VT" value="VT">Vermont (VT)</option>
        <option id="USA-VA" value="VA">Virginia (VA)</option>
        <option id="USA-VI" value="VI">Virgin Islands (VI)</option>
        <option id="USA-WA" value="WA">Washington (WA)</option>
        <option id="USA-WV" value="WV">West Virginia (WV)</option>
        <option id="USA-WI" value="WI">Wisconsin (WI)</option>
        <option id="USA-WY" value="WY">Wyoming (WY)</option>
      </optgroup>
    EOF
    if CartConfig.get(:ship_to_canada, :payment)
      rv +=  <<-EOF
        <optgroup label="Canada">
          <option id="CAN-AB" value="AB">Alberta (AB)</option>
          <option id="CAN-BC" value="BC">British Columbia (BC)</option>
          <option id="CAN-MB" value="MB">Manitoba (MB)</option>
          <option id="CAN-NB" value="NB">New Brunswick (NB)</option>
          <option id="CAN-NL" value="NL">Newfoundland and Labrador (NL)</option>
          <option id="CAN-NT" value="NT">Northwest Territories (NT)</option>
          <option id="CAN-NS" value="NS">Nova Scotia (NS)</option>
          <option id="CAN-NU" value="NU">Nunavut (NU)</option>
          <option id="CAN-PE" value="PE">Prince Edward Island (PE)</option>
          <option id="CAN-SK" value="SK">Saskatchewan (SK)</option>
          <option id="CAN-ON" value="ON">Ontario (ON)</option>
          <option id="CAN-QC" value="QC">Quebec (QC)</option>
          <option id="CAN-YT" value="YT">Yukon (YT)</option>
        </optgroup>
      EOF
    end
    rv += '</select>'
    rv
  end

end
