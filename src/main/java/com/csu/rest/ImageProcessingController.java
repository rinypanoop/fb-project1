package com.csu.rest;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
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
import com.google.appengine.api.datastore.Entity;
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
	public String getAllEmployees(Model model, @RequestParam String fromDate, @RequestParam String toDate, @RequestParam String access_token){

		System.out.println(fromDate);
		System.out.println(toDate);

		Images images = new Images();
		model.addAttribute("images", images);

		try {
			FbAlbums albums = getPhotosFromFb(access_token,1);

			System.out.println(albums.getData().get(0).getId());

			if(null != albums && !albums.getData().isEmpty()) {
				albums.getData().forEach(album -> {
					if(null !=  album.getPhotos() && null != album.getPhotos().getData() && !album.getPhotos().getData().isEmpty()) {
						album.getPhotos().getData().forEach( photo -> {

							//TODO add code to check in google data store, if it is already processed. 
							//photo.getId();

							List<EntityAnnotation> imageLabels = getImageLabels(photo.getPicture());

							if(null != imageLabels) {
								saveToDataStore(imageLabels,photo);
							}
						});
					}
				});
			}


		} catch (IOException e) {
			e.printStackTrace();
		}


		return "jsonview";
	}


	public static byte[] downloadFile(URL url) throws Exception {
		try (InputStream in = url.openStream()) {
			byte[] bytes = IOUtils.toByteArray(in);            
			return bytes;
		}
	}


	private void saveToDataStore(List<EntityAnnotation> imageLabels, Datum_ photo) {
		Entity user = new Entity("User");
		user.setProperty("fb_post_date", photo.getCreatedTime());
		user.setProperty("fb_image_id", photo.getId());
		user.setProperty("image_url", photo.getPicture());

		List<String> lables = imageLabels.stream().filter(label -> label.getScore() * 100 > 95)
				.map(EntityAnnotation::getDescription).collect(Collectors.toList());
		user.setProperty("lables", lables);
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

	private FbAlbums getPhotosFromFb(String access_token, int limit ) throws IOException {
		CloseableHttpClient httpClient = HttpClients.createDefault();
		FbAlbums fbAlbum = null;
		try {
			String baseUrl = "https://graph.facebook.com/v9.0/me/albums";
			String parameters = "?fields=photos%7Bcreated_time%2Cid%2Cpicture%7D%2Cname&limit="+limit+"&access_token=";
			HttpGet request = new HttpGet(baseUrl + parameters + access_token);
			CloseableHttpResponse response = httpClient.execute(request);
			try {
				// Get HttpResponse Status
				System.out.println(response.getProtocolVersion());              // HTTP/1.1
				System.out.println(response.getStatusLine().getStatusCode());   // 200
				System.out.println(response.getStatusLine().getReasonPhrase()); // OK
				System.out.println(response.getStatusLine().toString());        // HTTP/1.1 200 OK

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
