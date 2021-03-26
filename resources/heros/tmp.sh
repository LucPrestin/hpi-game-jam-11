a=1
for x in *.png; do
  mv -i -- "$x" "player_$a.png"
  let a=a+1
done
