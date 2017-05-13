// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

import 'package:pub_dartlang_org/templates.dart';
import 'package:pub_dartlang_org/search_service.dart'
    show SearchQuery, SearchResultPage;

import 'utils.dart';

void main() {
  group('templates', () {
    final templates = new TemplateService(templateDirectory: 'views');

    void expectGoldenFile(String content, String fileName) {
      final golden = new File('test/golden/$fileName').readAsStringSync();
      expect(content.split('\n'), golden.split('\n'));
    }

    test('index page', () {
      final String html = templates
          .renderIndexPage([testPackageVersion, flutterPackageVersion]);
      expectGoldenFile(html, 'index_page.html');
    });

    test('package show page', () {
      final String html = templates.renderPkgShowPage(
          testPackage,
          [testPackageVersion],
          [Uri.parse('http://dart-example.com/')],
          testPackageVersion,
          testPackageVersion,
          testPackageVersion,
          1);
      expectGoldenFile(html, 'pkg_show_page.html');
    });

    test('package show page with flutter_plugin', () {
      final String html = templates.renderPkgShowPage(
          testPackage,
          [flutterPackageVersion],
          [Uri.parse('http://dart-example.com/')],
          flutterPackageVersion,
          flutterPackageVersion,
          flutterPackageVersion,
          1);
      expectGoldenFile(html, 'pkg_show_page_flutter_plugin.html');
    });

    test('package index page', () {
      final String html = templates.renderPkgIndexPage(
          [testPackage, testPackage],
          [testPackageVersion, flutterPackageVersion],
          new PackageLinks.empty());
      expectGoldenFile(html, 'pkg_index_page.html');
    });

    test('package versions page', () {
      final String html = templates.renderPkgVersionsPage(testPackage.name,
          [testPackageVersion], [Uri.parse('http://dart-example.com/')]);
      expectGoldenFile(html, 'pkg_versions_page.html');
    });

    test('flutter plugins - index page #2', () {
      final String html = templates.renderPkgIndexPage(
        [testPackage],
        [flutterPackageVersion],
        new PackageLinks(
            PackageLinks.RESULTS_PER_PAGE, PackageLinks.RESULTS_PER_PAGE + 1),
        title: 'Flutter Plugins',
        faviconUrl: LogoUrls.flutterLogo32x32,
        descriptionHtml: flutterPluginsDescriptionHtml,
      );
      expectGoldenFile(html, 'flutter_plugins_index_page2.html');
    });

    test('search page', () {
      final query = new SearchQuery('foobar', offset: 0);
      final resultPage = new SearchResultPage(
          query,
          2,
          [testPackageVersion, flutterPackageVersion],
          [testPackageVersion, flutterPackageVersion]);
      final String html =
          templates.renderSearchPage(resultPage, new SearchLinks(query, 2));
      expectGoldenFile(html, 'search_page.html');
    });

    test('sitemap page', () {
      final String html = templates.renderSitemapPage();
      expectGoldenFile(html, 'sitemap_page.html');
    });

    test('authorized page', () {
      final String html = templates.renderAuthorizedPage();
      expectGoldenFile(html, 'authorized_page.html');
    });

    test('error page', () {
      final String html = templates.renderErrorPage(
          'error_status', 'error_message', 'error_traceback');
      expectGoldenFile(html, 'error_page.html');
    });

    test('pagination: single page', () {
      final String html = templates.renderPagination(new PackageLinks.empty());
      expectGoldenFile(html, 'pagination_single.html');
    });

    test('pagination: in the middle', () {
      final String html = templates.renderPagination(new PackageLinks(90, 299));
      expectGoldenFile(html, 'pagination_middle.html');
    });

    test('pagination: at first page', () {
      final String html = templates.renderPagination(new PackageLinks(0, 600));
      expectGoldenFile(html, 'pagination_first.html');
    });

    test('pagination: at last page', () {
      final String html = templates.renderPagination(new PackageLinks(90, 91));
      expectGoldenFile(html, 'pagination_last.html');
    });
  });

  group('PageLinks', () {
    test('empty', () {
      final links = new PackageLinks.empty();
      expect(links.currentPage, 1);
      expect(links.leftmostPage, 1);
      expect(links.rightmostPage, 1);
    });

    test('one', () {
      final links = new PackageLinks(0, 1);
      expect(links.currentPage, 1);
      expect(links.leftmostPage, 1);
      expect(links.rightmostPage, 1);
    });

    test('PackageLinks.RESULTS_PER_PAGE - 1', () {
      final links = new PackageLinks(0, PackageLinks.RESULTS_PER_PAGE - 1);
      expect(links.currentPage, 1);
      expect(links.leftmostPage, 1);
      expect(links.rightmostPage, 1);
    });

    test('PackageLinks.RESULTS_PER_PAGE', () {
      final links = new PackageLinks(0, PackageLinks.RESULTS_PER_PAGE);
      expect(links.currentPage, 1);
      expect(links.leftmostPage, 1);
      expect(links.rightmostPage, 1);
    });

    test('PackageLinks.RESULTS_PER_PAGE + 1', () {
      final links = new PackageLinks(0, PackageLinks.RESULTS_PER_PAGE + 1);
      expect(links.currentPage, 1);
      expect(links.leftmostPage, 1);
      expect(links.rightmostPage, 2);
    });

    final int page2Offset = PackageLinks.RESULTS_PER_PAGE;

    test('page=2 + one item', () {
      final links = new PackageLinks(page2Offset, page2Offset + 1);
      expect(links.currentPage, 2);
      expect(links.leftmostPage, 1);
      expect(links.rightmostPage, 2);
    });

    test('page=2 + PackageLinks.RESULTS_PER_PAGE - 1', () {
      final links = new PackageLinks(
          page2Offset, page2Offset + PackageLinks.RESULTS_PER_PAGE - 1);
      expect(links.currentPage, 2);
      expect(links.leftmostPage, 1);
      expect(links.rightmostPage, 2);
    });

    test('page=2 + PackageLinks.RESULTS_PER_PAGE', () {
      final links = new PackageLinks(
          page2Offset, page2Offset + PackageLinks.RESULTS_PER_PAGE);
      expect(links.currentPage, 2);
      expect(links.leftmostPage, 1);
      expect(links.rightmostPage, 2);
    });

    test('page=2 + PackageLinks.RESULTS_PER_PAGE + 1', () {
      final links = new PackageLinks(
          page2Offset, page2Offset + PackageLinks.RESULTS_PER_PAGE + 1);
      expect(links.currentPage, 2);
      expect(links.leftmostPage, 1);
      expect(links.rightmostPage, 3);
    });

    test('deep in the middle', () {
      final links = new PackageLinks(200, 600);
      expect(links.currentPage, 21);
      expect(links.leftmostPage, 16);
      expect(links.rightmostPage, 26);
    });
  });

  group('URLs', () {
    test('CSE query text parameter', () {
      var query = new SearchQuery('web framework');
      expect(query.buildCseQueryText(), 'web framework');

      query = new SearchQuery('web framework', type: 'pkg_type');
      expect(query.buildCseQueryText(),
          'web framework more:pagemap:document-dt_pkg_type:1');
    });

    test('SearchLinks defaults', () {
      final query = new SearchQuery('web framework');
      final SearchLinks links = new SearchLinks(query, 100);
      expect(links.formatHref(1), '/search?q=web+framework&page=1');
      expect(links.formatHref(2), '/search?q=web+framework&page=2');
    });

    test('SearchLinks with type', () {
      final query = new SearchQuery('web framework', type: 'pkg_type');
      final SearchLinks links = new SearchLinks(query, 100);
      expect(
          links.formatHref(1), '/search?q=web+framework&page=1&type=pkg_type');
      expect(
          links.formatHref(2), '/search?q=web+framework&page=2&type=pkg_type');
    });
  });
}