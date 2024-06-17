mkdir ProfessionCooldown
cp .\LICENSE .\ProfessionCooldown\
cp .\*.lua .\ProfessionCooldown\
cp .\README.md .\ProfessionCooldown\
cp .\ProfessionCooldown.toc .\ProfessionCooldown\
cp .\embeds.xml .\ProfessionCooldown\
cp -r .\libs .\ProfessionCooldown\
7z.exe a ProfessionCooldown.zip .\ProfessionCooldown
rm -r .\ProfessionCooldown