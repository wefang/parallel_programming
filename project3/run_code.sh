mkdir -p output/CoinFlip

# Coin Flip Speedup
for j in {1..5}
do
echo "cycle $j"
for i in {1..32}
do
java CoinFlip $i 1000000000 >> ./output/CoinFlip/speedup.txt
done
done

grep "Startup" ./output/CoinFlip/speedup.txt > ./output/CoinFlip/startup_time.txt
grep "Running" ./output/CoinFlip/speedup.txt > ./output/CoinFlip/speedup_time.txt

mkdir -p output/SealedDES

# SealedDES Scaleup
for j in {1..5}
do
echo "cycle $j"
java SealedDES 1 20 >> ./output/SealedDES/scaleup.txt
java SealedDES 2 21 >> ./output/SealedDES/scaleup.txt
java SealedDES 4 22 >> ./output/SealedDES/scaleup.txt
java SealedDES 8 23 >> ./output/SealedDES/scaleup.txt
java SealedDES 16 24 >> ./output/SealedDES/scaleup.txt
done

grep "Completed" ./output/SealedDES/scaleup.txt > ./output/SealedDES/scaleup_time.txt

# DES extrapolation
for j in {1..5}
do
echo "cycle $j"
for i in {1..32}
do
	java SealedDES $i 21 >> ./output/SealedDES/extrapolation.txt
	java SealedDES $i 22 >> ./output/SealedDES/extrapolation.txt
	java SealedDES $i 23 >> ./output/SealedDES/extrapolation.txt
done
done

grep "Completed" ./output/SealedDES/extrapolation.txt > ./output/SealedDES/extra_time.txt

