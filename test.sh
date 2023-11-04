#!/bin/bash

ITEM_FILE=$1
DATA_FILE=$2
USER_FILE=$3

echo "--------------------------"
echo "User Name: MoonGyuwon"
echo "Student Number: 12223544"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item’"
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’"
echo "4. Delete the ‘IMDb URL’ from ‘u.item'"
echo "5. Get the data about users from 'u.user’"
echo "6. Modify the format of 'release date' in 'u.item’"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

while true; do
    echo -n "Enter your choice [1-9]: "
    read choice
    echo

    case $choice in
        1)
            echo -n "Please enter the 'movie id’(1~1682): "
            read movie_id
            echo

            cat $ITEM_FILE | awk -F\| -v id=$movie_id '$1 == id { print $0 }'
            echo
            ;;

        2)
            echo -n "Do you want to get the data of ‘action’ genre movies from 'u.item’?(y/n): "
            read answer2
            echo

            if [ "$answer2" == "y" ]; then
                cat "$ITEM_FILE" | awk -F\| '$7 == "1" {print $1, $2}' | sort -n | head -10

            echo
            fi
            ;;

        3)
            echo -n "Please enter the 'movie id’(1~1682): "
            read movie_id
            echo

            average_rating=$(awk -F"\t" -v id=$movie_id '$2 == id { total_rating+=$3; cnt++ } END { printf "%.5f", total_rating/cnt }' $DATA_FILE)
            echo "average rating of $movie_id: $average_rating"
            echo
            ;;

        4)
            echo -n "Do you want to delete the ‘IMDb URL’ from ‘u.item’?(y/n): "
            read answer4
            echo

            if [ "$answer4" == "y" ]; then
                sed 's|http://[^|]*||' "$ITEM_FILE" > del_IMDb.txt
                head -10 del_IMDb.txt
            echo
            fi
            ;;

        5)
            echo -n "Do you want to get the data about users from ‘u.user’?(y/n): "
            read answer5
            echo

            if [ "$answer5" == "y" ]; then
                awk -F"|" 'NR <= 10 {
                    if ($3 == "M") { gender = "male"}
                    else {gender = "female"}
                print "user", $1, "is", $2, "years old", gender, $4 }' $USER_FILE
            echo
            fi
            ;;

        6)
            echo -n "Do you want to Modify the format of ‘release data’ in ‘u.item’?(y/n): "
            read answer6
            echo

            if [ "$answer6" == "y" ]; then
                tail -10 $ITEM_FILE | awk -F"|" '{
                    if (!month["Jan"]) {
                        split("Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec", months, ",");
                        for(i=1; i<=12; i++) {
                            month[months[i]] = sprintf("%02d", i);
                        }
                    }

                    split($3, arr_date, "-");
                    date_reformat = arr_date[3] month[arr_date[2]] arr_date[1];
                    $3 = date_reformat;
                    print $0
            }' OFS="|"

            echo
            fi
            ;;

        7)
            echo -n "Please enter the 'user id'(1~943): "
            read user_id
            echo

            movie_id=$(awk -v id=$user_id -F"\t" '$1 == id {print $2}' $DATA_FILE | sort -n)
            echo "$movie_id" | tr '\n' '|' | sed 's/|$//'
            echo

            echo
            echo "$movie_id" | head -10 | while read movie_id_10; do
                movie_title=$(awk -v m_id=$movie_id_10 -F"|" '$1 == m_id {print $2}' $ITEM_FILE)
                echo "$movie_id_10|$movie_title"
            done
            echo
            ;;

        8)
            echo -n "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n): "
            read answer8
            echo

            if [[ "$answer8" == "y" ]]; then
                ids_programmer=$(awk -F'|' '$2 >= 20 && $2 <= 29 && $4 == "programmer" {print $1}' $USER_FILE)
                awk -F'\t' -v ids_p="$ids_programmer" 'BEGIN {split(ids_p, arr_id, " ")}
                    { for (i in arr_id) if ($1 == arr_id[i]) { total_rate[$2] += $3; cnt[$2]++ } }
                    END {
                        for (id in total_rate) {
                            average_rate = total_rate[id]/cnt[id];
                            if (average_rate == int(average_rate))
                                printf "%s %d\n", id, average_rate;
                            else {
                                formatted_average_rate = sprintf("%.5f", average_rate);
                                gsub(/0+$/, "", formatted_average_rate);   
                                gsub(/\.$/, "", formatted_average_rate);  
                                printf "%s %s\n", id, formatted_average_rate;
                            }
                        }
                    }' $DATA_FILE | sort -k1,1n
            echo
            fi
            ;;

        9)
            echo "Bye!"
            exit 0
            ;;


    esac
done
