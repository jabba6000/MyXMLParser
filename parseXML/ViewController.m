//
//  ViewController.m
//  parseXML
//
//  Created by Uri Fuholichev on 10/4/16.
//  Copyright © 2016 Andrei Karpenia. All rights reserved.
//

#import "ViewController.h"

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

@end

@implementation ViewController

- (void)viewDidLoad {
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
    
    // Keep the current element.
    self.currentElement = elementName;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"offer"]) {
        // If the closing element equals to "geoname" then the all the data of a neighbour country has been parsed and the dictionary should be added to the neighbours data array.
        [self.arrNeighboursData addObject:[[NSDictionary alloc] initWithDictionary:self.dictTempDataStorage]];
    }
    else if ([elementName isEqualToString:@"name"]){
        // If the country name element was found then store it.
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"name"];
        NSLog(@"%@", self.foundValue);
    }
    else if ([elementName isEqualToString:@"categoryId"]){
        // If the toponym name element was found then store it.
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"categoryId"];
        NSLog(@"%@", self.foundValue);
    }
    
    // Clear the mutable string.
    [self.foundValue setString:@""];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // Store the found characters if only we're interested in the current element.
    if ([self.currentElement isEqualToString:@"name"] ||
        [self.currentElement isEqualToString:@"categoryId"]) {
        
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSLog(@"%@", [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"name"]);
    
    cell.textLabel.text = [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [[self.arrNeighboursData objectAtIndex:indexPath.row] objectForKey:@"categoryId"];
    
    return cell;
}

@end
