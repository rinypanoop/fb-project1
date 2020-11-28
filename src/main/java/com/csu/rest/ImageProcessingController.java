package com.csu.rest;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.TreeSet;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpEntity;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.csu.rest.model.Datum_;
import com.csu.rest.model.FbAlbums;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.CompositeFilterOperator;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;
import com.google.cloud.vision.v1.AnnotateImageRequest;
import com.google.cloud.vision.v1.AnnotateImageResponse;
import com.google.cloud.vision.v1.BatchAnnotateImagesResponse;
import com.google.cloud.vision.v1.EntityAnnotation;
import com.google.cloud.vision.v1.Feature;
import com.google.cloud.vision.v1.Image;
import com.google.cloud.vision.v1.ImageAnnotatorClient;
import com.google.protobuf.ByteString;


@Controller
@RequestMapping("/")
public class ImageProcessingController {


	@GetMapping("/")
	public String index(Model model) {
		return "index";
	}

	@PostMapping("/home")
	public String home(Model model, HttpServletRequest request, HttpServletResponse response) {
		System.out.println(request.getParameter("access_token"));

		model.addAttribute("access_token", request.getParameter("access_token"));
		model.addAttribute("user_name", request.getParameter("user_name"));
		model.addAttribute("user_id", request.getParameter("user_id"));
		return "home";
	}

	@GetMapping(value = "/images")
	public String getAllEmployees(Model model, @RequestParam String fromDate, @RequestParam String toDate, @RequestParam String access_token, String user_id){

		//Get Images from FB, run vision and store in data store.
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
		getImagesFromFbAndStoreinDataStore(access_token, datastore, user_id);


		//Get data for a given date from data store and send response.
		ImageDataResponse imageDataResponse =  getImagesFromStore(datastore,fromDate, toDate, user_id);
		model.addAttribute("imageDataResponse", imageDataResponse);

		return "jsonview";
	}

	private void getImagesFromFbAndStoreinDataStore(String access_token, DatastoreService datastore, String user_id) {
		try {
			int limit = 1; //TODO increase the limit 
			String baseUrl = "https://graph.facebook.com/v9.0/me/albums";
			String parameters = "?fields=photos%7Bcreated_time%2Cid%2Cpicture%7D%2Cname&limit="+limit+"&access_token=";

			String url = baseUrl + parameters + access_token;

			// This is to work with FB paging
			int count = 0;
			while(StringUtils.isNotBlank(url) && count <= 3) {
				count++;
				FbAlbums albums = getPhotosFromFb(url);
				if(null != albums && !albums.getData().isEmpty()) {
					albums.getData().forEach(album -> {
						if(null !=  album.getPhotos() && null != album.getPhotos().getData() && !album.getPhotos().getData().isEmpty()) {
							album.getPhotos().getData().forEach( photo -> {

								//TODO Check if the image is already present in the data store and process google vision if not present.

								Entity user = checkIfPresent(datastore, photo.getId());
								if(null == user) {
									//Process and fetch image lables using google vision analytics.
									List<EntityAnnotation> imageLabels = getImageLabels(photo.getPicture());

									//Save the imageId, image URL and lables to data store
									if(null != imageLabels) {
										user = saveToDataStore(imageLabels, photo, datastore, user_id);
									}
								}

							});
						}
					});
					url =  null != albums.getPaging() ? albums.getPaging().getNext() : null;	
				}else {
					url = null;
				}

			}

		} catch (IOException e) {
			e.printStackTrace();
		}
	}


	//Query data store to check if the image is already present.
	private Entity checkIfPresent(DatastoreService datastore, String fbPhotoId) {
		Query q =
				new Query("User")
				.setFilter(new FilterPredicate("fb_image_id", FilterOperator.EQUAL, fbPhotoId));
		PreparedQuery pq = datastore.prepare(q);
		Entity result = pq.asSingleEntity();
		return result;
	}


	//Query data store to check if the image is already present.
	private ImageDataResponse getImagesFromStore(DatastoreService datastore, String fromDate, String toDate, String user_id ) {
		List<String> imageList = new ArrayList<String>();
		imageList.add("Flower");

		Query query =
				new Query("User");

		DateFormat originalFormat = new SimpleDateFormat("MM/dd/yyyy", Locale.ENGLISH);
		try {
			Date search_from_date = originalFormat.parse(fromDate);
			Date search_to_date = originalFormat.parse(toDate);

			Filter fromFilter = new FilterPredicate("fb_post_date", FilterOperator.GREATER_THAN_OR_EQUAL, search_from_date);

			Filter toFIlter = new FilterPredicate("fb_post_date", FilterOperator.LESS_THAN_OR_EQUAL, search_to_date);
			
			Filter userFilter = new FilterPredicate("user_id", FilterOperator.EQUAL, user_id);

			Filter dateFilter = CompositeFilterOperator.and(fromFilter, toFIlter, userFilter);

			query.setFilter(dateFilter);

		} catch (ParseException e) {
			e.printStackTrace();
		}



		PreparedQuery pq = datastore.prepare(query);
		List<Entity> results = pq.asList(FetchOptions.Builder.withDefaults());

		Set<String> lables = new TreeSet<>();
		List<com.csu.rest.Image> images = new ArrayList<>();

		if(null != results) {
			results.forEach(user -> {
				List<String> lablesFromStore = (List<String>) user.getProperty("lables");
				lables.addAll(lablesFromStore);
				com.csu.rest.Image image = new com.csu.rest.Image();
				image.setUrl(user.getProperty("image_url").toString());
				image.setLabels(lablesFromStore);
				images.add(image);
			});
		}


		ImageDataResponse imageDataResponse = new ImageDataResponse();

		imageDataResponse.setImages(images);
		imageDataResponse.setLables(lables);


		return imageDataResponse;
	}


	public static byte[] downloadFile(URL url) throws Exception {
		try (InputStream in = url.openStream()) {
			byte[] bytes = IOUtils.toByteArray(in);            
			return bytes;
		}
	}


	//Saving to data store.
	private Entity saveToDataStore(List<EntityAnnotation> imageLabels, Datum_ photo, DatastoreService datastore, String user_id) {

		List<String> lables = imageLabels.stream().filter(label -> label.getScore() * 100 > 95)
				.map(EntityAnnotation::getDescription).collect(Collectors.toList());

		if(null != lables && !lables.isEmpty()) {

			Entity user = new Entity("User");


			DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
			Date fb_date = null;
			try {
				fb_date = originalFormat.parse(photo.getCreatedTime());
			} catch (ParseException e) {
				e.printStackTrace();
			}

			user.setProperty("fb_post_date", fb_date);
			user.setProperty("user_id", user_id);
			user.setProperty("fb_image_id", photo.getId());
			user.setProperty("image_url", photo.getPicture());
			user.setProperty("created_on", new Date());
			user.setProperty("lables", lables);

			datastore.put(user);

			return user;

		}
		return null;
	}

	private List<EntityAnnotation> getImageLabels(String imageUrl) {
		try {
			byte[]  imgBytes = downloadFile(new URL(imageUrl));
			ByteString byteString = ByteString.copyFrom(imgBytes);
			Image image = Image.newBuilder().setContent(byteString).build();

			Feature feature = Feature.newBuilder().setType(Feature.Type.LABEL_DETECTION).build();
			AnnotateImageRequest request =
					AnnotateImageRequest.newBuilder().addFeatures(feature).setImage(image).build();
			List<AnnotateImageRequest> requests = new ArrayList<>();
			requests.add(request);

			ImageAnnotatorClient client = ImageAnnotatorClient.create();
			BatchAnnotateImagesResponse batchResponse = client.batchAnnotateImages(requests);
			client.close();
			List<AnnotateImageResponse> imageResponses = batchResponse.getResponsesList();
			AnnotateImageResponse imageResponse = imageResponses.get(0);

			if (imageResponse.hasError()) {
				System.err.println("Error getting image labels: " + imageResponse.getError().getMessage());
				return null;
			}

			return imageResponse.getLabelAnnotationsList();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	private FbAlbums getPhotosFromFb(String url) throws IOException {
		CloseableHttpClient httpClient = HttpClients.createDefault();
		FbAlbums fbAlbum = null;
		try {

			HttpGet request = new HttpGet(url);

			CloseableHttpResponse response = httpClient.execute(request);
			try {
				System.out.println(response.getStatusLine().getStatusCode());   // 200
				HttpEntity entity = response.getEntity();
				if (entity != null) {
					String result = EntityUtils.toString(entity);
					System.out.println(result);
					ObjectMapper mapper = new ObjectMapper();
					fbAlbum = mapper.readValue(result, FbAlbums.class);	
				}

			} finally {
				response.close();
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			httpClient.close();
		}

		return fbAlbum;
	}
}
