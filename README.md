# OSWebFont(**O**pen**S**ource **WebFont**s)
OSWebFont(**O**pen**S**ource **WebFont**s Repo)

A Repo Of OpenSource WebFonts + Frontend Builder

Please note. This is still pre 1.0 there are things listed below that are comming but may not be baked in yet.

Adding fonts

We welcome commits to this repo. As such anyone can commit opensource fonts. In order to do so you will need to follow the requirements and rules.

Requirements
* All fonts must be contained within a folder within the fonts folder this folder must be the name of the font and must be unique and be websafe so no spaces etc

 * Within this folder you need to include:
  * A info.json file. Copy this from one of the fonts already listed.
  * A licence.md file. This must contain a copy of the licence in Markdown format.
  * The font File

Rules
* If the font does not belong to you, you must make sure that the font is opensource and permitted to be redistrbuted without the original creators permission.
* You must make sure the font does not already exist in the font libary. If it does not then also check pull requests to make sure that it is not already pending.


Configuration

All the configuration of this script is done in the config/config.json file. The file breaks down into the following

**build_path**
This should be set to a folder that already exists on the drive and the user running the script has access to. This will be where the files are built to before being copied to the production environment

**copy_to_path**
This is where the script will copy the built files too after having being built. This will be where you set your webserver to.

**gen_preview_string**
This defines what text will be shown in the preview string. It will also be used for the text volume analysis. The default contains all the charaters and symbols so only change if you have a string that will also meet the same criteria.

**gen_disclamer**
Enter any text here you would like to include as a disclamer. This will be shown on the HTML versions of the static files.

**gen_domain**
Set this text to the domain name of your server. It should not contain http or https.

**html_title**
This will define what is shown in the titlebar of the HTML webpage.

**build_content_rating**
Include the font ratings that you want to include. While at the moment there are no explicit fonts included there is no reason why this may not change. If you do not want to build explicit fonts just remove the string from the array.

**build_content_type**
Modify this however you like. You can remove any sort of type of font.

**exclude_licence_containing**
You can exclude any font based on the licence requirements. For example if fonts are going to be used for commercial purposes you obay the licence. For this reason if you do need to do this you can add the licence type to the array

**other_font_location**
You can set this string if you have your own selection of fonts that are not included in this libary. These must follow the same folder convention used in this library. Any font should also use a diffrent folder name from any listed in this repo as it can cause conflicts with the json ID structure.

**whitelist**
Add any folder name into this array that for whatever reason fails to build based on critera set.

**blacklist**
Reverse of witelist. Will block even if it passes the critera

**analyse[0]**
Will analyse the volume of the font. But not restrict any fonts

**analyse[1]**
If set to true the font will fail if any charater is lower than the percentage set in the array within this array. The array is layed out the same way as gen_preview_string.

**skip_version_check**
If set to true the script will not check to see if the font has already been built and as such will reprocess all the fonts. You should set this to true if you have changes any of the variables in this json script so that they can be reprocessed.

**no_antialias_on_analyse**
If set to true and analyse[0] set to true then it will not use antialiasing on the analysis. This should be keept as is unless you know what your doing.

