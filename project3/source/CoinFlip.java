import java.util.Random;

class CoinFlip implements Runnable {
    int id;
    long size;
    public long heads = 0L;
    Random generator = new Random();

    CoinFlip(int id, long size){
        this.id = id;
        this.size = size;
    }
   
    public void run() {
        for ( int i=0; i < size; i++ ) {
            this.heads += generator.nextInt(2);
        }
    }

    public static void main (String[] args) {
        if ( 2 != args.length ) {
            System.out.println("Usage: jave CoinFlip #threads #iterations");
            return;
        }
        
        long tstart = System.currentTimeMillis();
        int num_thread = Integer.parseInt(args[0]);
        int num_iter = Integer.parseInt(args[1]);
        long total_heads = 0;

        long sstart = System.nanoTime();

        CoinFlip[] coin_flips = new CoinFlip[num_thread];
        Thread[] threads = new Thread[num_thread];
        for (int i=0; i < num_thread; i++) {
            coin_flips[i] = new CoinFlip(i, num_iter/num_thread);
            threads[i] = new Thread(coin_flips[i]);
            threads[i].start();
        }

        long srun = (System.nanoTime() - sstart) / 1000;
        System.out.println("Startup Time: " + srun + " microseconds");
            

        for ( int i=0; i < num_thread; i++) {
            try {
                threads[i].join();
                total_heads += coin_flips[i].heads;
            }
            catch (InterruptedException e)
            {
                System.out.println("Thread interrupted. Exception: " + e.toString() +
                        " Message: " + e.getMessage());
                return;
            }
        }

        long trun = System.currentTimeMillis() - tstart;

        System.out.println(total_heads + " heads in " + num_iter + " coin tosses.");
        System.out.println("Running time: " + trun + " milliseconds");
    }
}
