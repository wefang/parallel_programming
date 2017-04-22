import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class TriangleCount {

	public static class TriadMapper
		extends Mapper<Object, Text, Text, IntWritable>{

			private final static IntWritable one = new IntWritable(1);
			private Text triad_text = new Text();

			public void map(Object key, Text value, Context context
				       ) throws IOException, InterruptedException {
				String[] person = value.toString().split("\\s+");
				int[] triad = new int[3];
				int n = person.length;
				if (n > 2) {
					for (int i = 1; i < n; i++) {
						for (int j = i+1; j < n; j++) {
							triad[0] = Integer.parseInt(person[0]);
							triad[1] = Integer.parseInt(person[i]);
							triad[2] = Integer.parseInt(person[j]);

							if (triad[1] < triad[2]){
								triad_text.set(triad[0] + " " + triad[1] + " " + triad[2]);
							} else {
								triad_text.set(triad[0] + " " + triad[2] + " " + triad[1]);
							}
							context.write(triad_text, one);

							if (triad[0] < triad[2]){
								triad_text.set(triad[1] + " " + triad[0] + " " + triad[2]);
							} else {
								triad_text.set(triad[1] + " " + triad[2] + " " + triad[0]);
							}
							context.write(triad_text, one);

							if (triad[0] < triad[1]){
								triad_text.set(triad[2] + " " + triad[0] + " " + triad[1]);
							} else {
								triad_text.set(triad[2] + " " + triad[1] + " " + triad[0]);
							}
							context.write(triad_text, one);
						}
					}
				}
			}
		}


	public static class TriangleReducer
		extends Reducer<Text, IntWritable, Text, NullWritable> {
			NullWritable nw = NullWritable.get();
			public void reduce(Text key, Iterable<IntWritable> values,
					Context context
					) throws IOException, InterruptedException {
				int sum = 0;
				for (IntWritable val : values) {
					sum += val.get();
				}
				if (sum >= 3) {
					context.write(key, nw);
				}
			}
		}

	public static void main(String[] args) throws Exception {
		Configuration conf = new Configuration();
		Job job = Job.getInstance(conf, "triangle count");
		job.setJarByClass(TriangleCount.class);
		job.setMapperClass(TriadMapper.class);
		job.setReducerClass(TriangleReducer.class);
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(IntWritable.class);
		FileInputFormat.addInputPath(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));
		System.exit(job.waitForCompletion(true) ? 0 : 1);
	}
}
