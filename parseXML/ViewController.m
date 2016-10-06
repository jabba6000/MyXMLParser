//
//  ViewController.m
//  parseXML
//
//  Created by Uri Fuholichev on 10/4/16.
//  Copyright © 2016 Andrei Karpenia. All rights reserved.
//

#import "ViewController.h"
#import "MyCustomCell.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

// The xmlParser property is the one that we’ll use to parse the XML data.
@property (nonatomic, strong) NSXMLParser *xmlParser;
// Array that will contain all of the desired data after the parsing has finished.
@property (nonatomic, strong) NSMutableArray *arrNeighboursData;
// We’ll temporarily store the two values we seek for each neighbour country until we add it to the array.
@property (nonatomic, strong) NSMutableDictionary *dictTempDataStorage;
// The foundValue mutable string will be used to store the found characters of the elements of interest.
@property (nonatomic, strong) NSMutableString *foundValue;
// The currentElement string will be assigned with the name of the element that is parsed at any moment.
@property (nonatomic, strong) NSString *currentElement;

//
@property (nonatomic, strong) NSMutableArray *arrayWithImages;


//Extra properties for Cell
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfig;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    _arrayWithImages = [NSMutableArray new];
    for (int x = 0; x!=260; x++){
        NSInteger nsi = (NSInteger) x;
        [_arrayWithImages insertObject:@"1" atIndex:nsi];
    }
    //For a Cell
    _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:_sessionConfig];
    
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    [super viewDidLoad];
    [self performParsing];
    [self.arrNeighboursData count];
}

- (void)performParsing{
    //создали экземпляр Парсера, объявляем его делегаты и парсим!
    self.xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://ufa.farfor.ru/getyml/?key=ukAXxeJYZN"]];
    [self.xmlParser setDelegate: self];
    
    // Initialize the mutable string that we'll use during parsing.
    self.foundValue = [[NSMutableString alloc] init];
    
    [self.xmlParser parse];
}

#pragma mark NSXMLParser Delegate methods

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    // Initialize the neighbours data array.
    self.arrNeighboursData = [[NSMutableArray alloc] init];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    // When the parsing has been finished then simply reload the table view.
    NSLog(@"COUNT IS %lu", (unsigned long)[self.arrNeighboursData count]);   
    [self.myTableView reloadData];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"%@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    // If the current element name is equal to "geoname" then initialize the temporary dictionary.
    if ([elementName containsString:@"offer"]) {
        self.dictTempDataStorage = [[NSMutableDictionary alloc] init];
    }
    
    if ([elementName containsString:@"param"]){
        if ([[attributeDict objectForKey:@"name"] isEqualToString: @"Вес"])
            self.currentElement = elementName;
    }
    
    // Keep the current element.
    self.currentElement = elementName;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"offer"]) {
        // If the closing element equals to "geoname" then the all the data of a neighbour country has been parsed and the dictionary should be added to the neighbours data array.
        [self.arrNeighboursData addObject:[[NSDictionary alloc] initWithDictionary:self.dictTempDataStorage]];
    }
    else if ([elementName isEqualToString:@"picture"]){
        //        NSURL *pictureURL = [NSURL URLWithString: self.foundValue];
        //        [self.dictTempDataStorage setObject:pictureURL forKey:@"pictureURL"];
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"picture"];
    }
    else if ([elementName isEqualToString:@"name"]){
        // If the country name element was found then store it.
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"name"];
    }
    else if ([elementName isEqualToString:@"categoryId"]){
        // If the toponym name element was found then store it.
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"categoryId"];
    }
    else if ([elementName isEqualToString:@"param"]){
        // If the toponym name element was found then store it.
        if([self.foundValue containsString:@"гр"]){
            NSString *weight = [self.foundValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            [self.dictTempDataStorage setObject:[NSString stringWithString:weight] forKey:@"weight"];
            NSLog(@"%@", weight);
        }
    }
   
    // Clear the mutable string.
    [self.foundValue setString:@""];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // Store the found characters if only we're interested in the current element.
    if ([self.currentElement isEqualToString:@"name"] ||
        [self.currentElement isEqualToString:@"categoryId"] ||
        [self.currentElement containsString:@"param"] ||
        [self.currentElement isEqualToString:@"picture"]) {
        if (![string isEqualToString:@"\n"]) {
            [self.foundValue appendString:string];
        }
    }
}

#pragma mark UITableView methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrNeighboursData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@", [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"name"]);

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.tag = indexPath.row;

    if ([self.arrNeighboursData objectAtIndex:indexPath.row])
    {
        if(  [[_arrayWithImages objectAtIndex:indexPath.row]  isEqual: @"1"]){
        cell.imageView.image = nil;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void) {
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"picture"]]];
            
                                 UIImage* image = [[UIImage alloc] initWithData:imageData];
                                 if (image) {
                                     [_arrayWithImages insertObject:image atIndex:indexPath.row];
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (cell.tag == indexPath.row) {
                                             cell.imageView.image = image;
                                             [cell setNeedsLayout];
                                         }
                                     });
                                 }
                                 });
                                 
                                 cell.textLabel.text = [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"name"];
                                cell.detailTextLabel.text = [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"weight"];

        }
        else if (![[_arrayWithImages objectAtIndex:indexPath.row ]  isEqual:@"1"] ){
            cell.imageView.image = [_arrayWithImages objectAtIndex:indexPath.row];
            cell.textLabel.text = [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.detailTextLabel.text = [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"weight"];
            [cell setNeedsLayout];
        }
    }
    return cell;
    
}
//    MyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//        if (cell == nil) {
//            cell = [[MyCustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
//            cell.accessoryType = UITableViewCellAccessoryNone;
//    //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//    
//    if (![[self.arrNeighboursData objectAtIndex:indexPath.row] valueForKey:@"readyImage"])
//    {
//        NSString *urlString = [[self.arrNeighboursData objectAtIndex:indexPath.row] valueForKey:@"picture"];
//        NSURL *imageURL = [NSURL URLWithString:urlString];
//        
//        if (imageURL)
//        {
//            NSLog(@"Url was created");
//            cell.imageDownloadTask = [_session dataTaskWithURL:imageURL
//                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//                                      {
//                                          if (error)
//                                          {
//                                              NSLog(@"ERROR: %@", error);
//                                          }
//                                          else
//                                          {
//                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//                                              NSLog(@"httpResponse was created");
//                                              if (httpResponse.statusCode == 200)
//                                              {
//                                                  UIImage *image = [UIImage imageWithData:data];
//                                                  
//                                                  dispatch_async(dispatch_get_main_queue(), ^{
//                                                      if([[self.arrNeighboursData objectAtIndex:indexPath.row] isKindOfClass:[NSMutableDictionary class]]) {
//                                                          [[self.arrNeighboursData objectAtIndex:indexPath.row] setObject:data forKey:@"readyImage"];}
//                                                      cell.imageView.image = image;
//                                                      if ([[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"readyImage"]) {
//                                                          cell.imageView.image = [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"readyImage"];
//                                                      }
//                                                      else{
//                                                          NSLog(@"shit");
//                                                      }
//                                                      [cell setNeedsLayout];
//                                                      [cell setNeedsDisplay];
//                                              
//                                                  });
//                                              }
//                                              else
//                                              {
//                                                  NSLog(@"Couldn't load image at URL: %@", imageURL);
//                                                  NSLog(@"HTTP %d", httpResponse.statusCode);
//                                              }
//                                          }
//                                      }];
//            
//            [cell.imageDownloadTask resume];
//        }
//    }
//    else
//    {
//        [cell.imageView setImage:[UIImage imageWithData:[[self.arrNeighboursData objectAtIndex:indexPath.row] valueForKey:@"readyImage"]]];
//    }
//    
//    cell.textLabel.text = [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"name"];
//    cell.detailTextLabel.text = [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"weight"];
//
//    return cell;
//}


@end
